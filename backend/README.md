# MogMap Backend

TypeScript + Express backend that proxies to the Anthropic Claude API.

## Setup

1. Install dependencies:
   npm install

2. Copy .env.example to .env and add your Anthropic API key:
   cp .env.example .env

3. Run in development mode:
   npm run dev

The server runs on http://localhost:3001

## Endpoints

- GET /health - Health check
- POST /api/quest - Generate a collaborative quest
  Body: { hotspotName, hotspotVibe, hotspotId, playerNames[] }
