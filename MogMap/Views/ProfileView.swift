import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel

    private let titles = [
        ("NPC", 0, Color.gray),
        ("Side Character", 100, Color.blue),
        ("Main Character", 500, Color(red: 0.486, green: 0.231, blue: 0.929)),
        ("Sigma", 2000, Color.orange),
        ("Chad", 10000, Color(red: 0.984, green: 0.753, blue: 0.141)),
        ("Tung Tung Tung Sahur", 15000, Color(red: 0.984, green: 0.753, blue: 0.141))
    ]

    private var profile: PlayerProfile {
        profileViewModel.profile
    }

    private var currentTierIndex: Int {
        switch profile.totalAura {
        case 0..<100: return 0
        case 100..<500: return 1
        case 500..<2000: return 2
        case 2000..<10000: return 3
        default: return 4
        }
    }

    private var tierColor: Color {
        titles[currentTierIndex].2
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Card
                    VStack(spacing: 16) {
                        // Title
                        VStack(spacing: 4) {
                            Text(profile.currentTitle)
                                .font(.system(size: 42, weight: .black))
                                .foregroundStyle(tierColor)
                            Text(profile.playerName)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }

                        // Aura Counter
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(profile.totalAura)")
                                .font(.system(size: 56, weight: .black))
                                .foregroundStyle(Color(red: 0.984, green: 0.753, blue: 0.141))
                            Text("AURA")
                                .font(.headline.bold())
                                .foregroundStyle(Color(red: 0.984, green: 0.753, blue: 0.141).opacity(0.7))
                                .padding(.bottom, 10)
                        }

                        // Percentile
                        Text(profile.percentileEstimate)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(tierColor.opacity(0.2))
                            .foregroundStyle(tierColor)
                            .cornerRadius(20)

                        Divider().opacity(0.3)

                        // Stats Row
                        HStack(spacing: 0) {
                            StatCell(value: "\(profile.questsCompleted)", label: "Quests")
                            Divider().frame(height: 40).opacity(0.3)
                            StatCell(value: "\(profile.currentStreak)🔥", label: "Streak")
                            Divider().frame(height: 40).opacity(0.3)
                            StatCell(value: "\(profile.longestStreak)", label: "Best Streak")
                        }
                    }
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.13, green: 0.13, blue: 0.22),
                                tierColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Title Progression
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title Progression")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(titles.indices, id: \.self) { index in
                                let (title, threshold, color) = titles[index]
                                let isCurrentTier = index == currentTierIndex
                                let isUnlocked = profile.totalAura >= threshold

                                HStack {
                                    Circle()
                                        .fill(isUnlocked ? color : Color.gray.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                    Text(title)
                                        .font(.subheadline)
                                        .fontWeight(isCurrentTier ? .bold : .regular)
                                        .foregroundStyle(isCurrentTier ? color : (isUnlocked ? .white : .secondary))
                                    Spacer()
                                    Text("\(threshold)+ aura")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    if isCurrentTier {
                                        Image(systemName: "chevron.left")
                                            .font(.caption.bold())
                                            .foregroundStyle(color)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(isCurrentTier ? color.opacity(0.1) : Color.clear)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)

                        // Progress Bar
                        if let nextAura = profile.auraForNextTitle {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Progress to \(profile.nextTitle ?? "")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(profile.totalAura) / \(nextAura)")
                                        .font(.caption.bold())
                                        .foregroundStyle(tierColor)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(tierColor)
                                            .frame(width: geo.size.width * profile.progressToNextTitle, height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(red: 0.13, green: 0.13, blue: 0.22))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
