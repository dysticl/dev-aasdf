import Combine
import SwiftUI

struct CountdownTimerView: View {
    let deadline: Date
    var fontSize: Font = .caption
    var showIcon: Bool = true
    var isCompact: Bool = false

    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            if isOverdue {
                if showIcon {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(SoloColors.dangerRed)
                }
                Text("ÜBERFÄLLIG")
                    .font(fontSize.weight(.bold))
                    .foregroundColor(SoloColors.dangerRed)
            } else {
                if showIcon {
                    Image(systemName: "timer")
                        .foregroundColor(SoloColors.textPrimary.opacity(0.7))
                }

                Text(timeString)
                    .monospacedDigit()
                    .font(fontSize.weight(.medium))
                    .foregroundColor(SoloColors.textPrimary)
            }
        }
        .onReceive(timer) { input in
            now = input
        }
    }

    var isOverdue: Bool {
        now > deadline
    }

    var timeString: String {
        let diff = deadline.timeIntervalSince(now)
        if diff <= 0 { return "00:00:00" }

        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60

        if isCompact {
            // For list view: shorter format
            if days > 0 {
                return String(format: "%dd %02dh", days, hours)
            } else {
                return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
            }
        } else {
            // Detailed format
            if days > 0 {
                return String(format: "%d Tage, %02d:%02d:%02d", days, hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
        }
    }
}

// Needed colors if not available in current scope (assuming SoloColors exists from context or I use standard)
// I saw SoloColors usage in HomeView.swift, so I assume it's global or imported.
// If it's not global, I might need to import AppTheme.swift logic.
// Checking imports in HomeView: "import SwiftUI" -> implies SoloColors is likely in AppTheme.swift or UIStyles.swift
