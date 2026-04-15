import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import Anthropic from '@anthropic-ai/sdk';
import { randomUUID } from 'crypto';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

function getAnthropicApiKey(): string | null {
  const apiKey = process.env.ANTHROPIC_API_KEY?.trim();

  if (!apiKey) {
    return null;
  }

  const looksPlaceholder = /your-key-here|placeholder|example/i.test(apiKey);
  if (looksPlaceholder || !apiKey.startsWith('sk-ant-')) {
    return null;
  }

  return apiKey;
}

function createFallbackQuest(hotspotName: string, hotspotId: string, playerNames: string[]) {
  return {
    id: randomUUID(),
    title: 'Squad Sigma Challenge',
    description: `Your crew has assembled at ${hotspotName} for a legendary team quest. Each player holds a secret piece of the puzzle. Coordinate, share your clues, and complete the challenge together. No cap this requires actual teamwork.`,
    auraReward: 75,
    difficulty: 'medium',
    timeEstimate: '10 min',
    hotspotId,
    pieces: playerNames.map((name, index) => {
      const roles = ['Riddle Keeper', 'Answer Guardian', 'Location Scout', 'Challenge Leader'];
      const clues = [
        'You hold the riddle: "I have hands but no arms, a face but no eyes, I tell the truth but never lie." Keep it secret until your team is ready.',
        'You have the answer key! The answer is "a clock." Reveal it only after your team has had 3 guesses.',
        `Scout the area! Find the most interesting or unique detail at ${hotspotName} and describe it to your team without saying what it is. Let them guess.`,
        'Lead the finale! Once the riddle is solved, get your whole squad to do a group sigma pose for a photo. You call the pose.',
      ];
      return {
        id: randomUUID(),
        playerName: name,
        role: roles[index % roles.length],
        clue: clues[index % clues.length],
      };
    }),
  };
}

const SYSTEM_PROMPT = `You are the Quest Master for MogMap, a collaborative campus exploration game at UW-Madison. Generate a TEAM side quest where multiple players get a piece of an overall puzzle. It should be a fun puzzle that takes brain power and collaboration to crack. Be creative with how pieces interconnect!

Use brainrot/gen-z tone: aura, mogging, side quest, touch grass, pressed, delulu, crash out, no cap, bussin, rizz, sigma, NPC, main character energy.

YOU decide the quest difficulty based on content complexity:
- easy (25-75 aura): quick silly team tasks
- medium (100-250 aura): requires actual coordination
- hard (300-500 aura): ambitious multi-step team challenges

Keep quests SAFE - no illegal activity, harassment, or dangerous stunts. Quests should be fun, social, and doable in 5-30 minutes on campus.

You will receive player names. Generate a unique piece for EACH player.

Respond with ONLY valid JSON, no markdown, no code blocks:
{
  "id": "<uuid>",
  "title": "<3-5 words>",
  "description": "<2-3 sentences describing the overall team challenge>",
  "auraReward": <number>,
  "difficulty": "<easy|medium|hard>",
  "timeEstimate": "<5 min|10 min|15 min|30 min>",
  "hotspotId": "<provided id>",
  "pieces": [
    {"id": "<uuid>", "playerName": "<name>", "role": "<2-3 word role title>", "clue": "<their unique piece/instruction, 1-2 sentences>"},
    ...one per player
  ]
}`;

interface QuestRequest {
  hotspotName: string;
  hotspotVibe: string;
  hotspotId: string;
  playerNames: string[];
}

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.post('/api/quest', async (req, res) => {
  const { hotspotName, hotspotVibe, hotspotId, playerNames } = req.body as QuestRequest;

  if (!hotspotName || !hotspotId || !playerNames?.length) {
    res.status(400).json({ error: 'Missing required fields: hotspotName, hotspotId, playerNames' });
    return;
  }

  const userPrompt = `Generate a collaborative quest for ${playerNames.length} players at ${hotspotName} (vibe: "${hotspotVibe}").

Players: ${playerNames.join(', ')}

Create a unique puzzle piece for each player. The pieces should interconnect so the team must coordinate to complete the overall challenge. Make it fun, creative, and specific to this location's vibe.

Use this exact hotspotId: ${hotspotId}
Generate fresh UUIDs for id and each piece's id.`;

  try {
    const apiKey = getAnthropicApiKey();
    if (!apiKey) {
      console.warn('ANTHROPIC_API_KEY is missing or still set to a placeholder. Returning fallback quest.');
      res.json(createFallbackQuest(hotspotName, hotspotId, playerNames));
      return;
    }

    const anthropic = new Anthropic({ apiKey });
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [
        { role: 'user', content: userPrompt }
      ],
    });

    const textContent = message.content.find(block => block.type === 'text');
    if (!textContent || textContent.type !== 'text') {
      throw new Error('No text content in response');
    }

    // Strip any markdown code fences if present
    let jsonText = textContent.text.trim();
    if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/^```[a-z]*\n?/, '').replace(/\n?```$/, '');
    }

    const quest = JSON.parse(jsonText);

    // Ensure all pieces have ids
    if (quest.pieces) {
      quest.pieces = quest.pieces.map((piece: { id?: string; playerName: string; role: string; clue: string }) => ({
        ...piece,
        id: piece.id || randomUUID(),
      }));
    }

    // Ensure quest has an id
    if (!quest.id) {
      quest.id = randomUUID();
    }

    res.json(quest);
  } catch (error) {
    console.error('Error generating quest:', error);
    res.json(createFallbackQuest(hotspotName, hotspotId, playerNames));
  }
});

app.listen(port, () => {
  console.log(`MogMap backend running on http://localhost:${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
});
