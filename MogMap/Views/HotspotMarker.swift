import SwiftUI

struct HotspotMarker: View {
    let hotspot: Hotspot
    @State private var isPulsing = false

    private var ringColor: Color {
        switch hotspot.radiusMeters {
        case 0..<100:
            return Color(red: 0.984, green: 0.753, blue: 0.141) // gold - small/rare
        case 100..<125:
            return Color(red: 0.486, green: 0.231, blue: 0.929) // purple - medium
        default:
            return Color(red: 0.2, green: 0.6, blue: 1.0) // blue - common
        }
    }

    private var isLegendary: Bool {
        hotspot.radiusMeters < 100
    }

    var body: some View {
        ZStack {
            if isLegendary {
                Circle()
                    .fill(ringColor.opacity(0.3))
                    .frame(width: 54, height: 54)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
            }

            Circle()
                .fill(Color(red: 0.102, green: 0.102, blue: 0.180))
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .strokeBorder(ringColor, lineWidth: 2.5)
                )

            Text(hotspot.emoji)
                .font(.system(size: 22))
        }
        .frame(width: 54, height: 54)
        .onAppear {
            if isLegendary {
                isPulsing = true
            }
        }
    }
}
