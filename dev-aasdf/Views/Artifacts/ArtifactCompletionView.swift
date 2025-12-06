//
//  ArtifactCompletionView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import SwiftUI

struct ArtifactCompletionView: View {
    let response: CompletionResponse
    @Environment(\.dismiss) var dismiss

    @State private var animateXP = false
    @State private var showContent = false

    var isRejected: Bool {
        response.status == "rejected"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background Glow
            Circle()
                .fill(isRejected ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .blur(radius: 150)
                .offset(x: 0, y: -100)

            VStack(spacing: 30) {
                Spacer()

                if isRejected {
                    // REJECTED UI
                    rejectedContent
                } else {
                    // SUCCESS UI
                    successContent
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text(isRejected ? "Try Again" : "Collect Rewards")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isRejected ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRejected ? Color.red : Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateXP = true
            }

            withAnimation(.easeOut.delay(0.5)) {
                showContent = true
            }
        }
    }

    // MARK: - Rejected Content

    private var rejectedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .scaleEffect(animateXP ? 1.0 : 0.5)
                .opacity(animateXP ? 1.0 : 0.0)

            Text("MISSION REJECTED")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.red)

            if showContent {
                VStack(alignment: .leading, spacing: 16) {
                    if let feedback = response.feedback, !feedback.isEmpty {
                        Text(feedback)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }

                    if let warnings = response.warnings, !warnings.isEmpty {
                        Divider().background(Color.white.opacity(0.2))

                        ForEach(warnings, id: \.self) { warning in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(warning)
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange.opacity(0.9))
                            }
                        }
                    }
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(
                        Color.red.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Success Content

    private var successContent: some View {
        VStack(spacing: 30) {
            // Level Up Badge (if leveled up)
            if let leveledUp = response.leveledUp, leveledUp {
                VStack {
                    Text("LEVEL UP!")
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 10)

                    if let newLevel = response.newLevel {
                        Text("\(newLevel)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Material.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }

            // XP Awarded
            VStack(spacing: 8) {
                Text("MISSION COMPLETED")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .tracking(2)

                if let xp = response.xpAwarded {
                    Text("+\(xp) XP")
                        .font(.system(size: 60, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                        .scaleEffect(animateXP ? 1.0 : 0.5)
                        .opacity(animateXP ? 1.0 : 0.0)
                }
            }

            if showContent {
                // AI Feedback Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                        Text("AI Analysis")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Spacer()
                    }

                    if let feedback = response.feedback, !feedback.isEmpty {
                        Text(feedback)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }

                    if let breakdown = response.breakdown {
                        Divider().background(Color.white.opacity(0.2))

                        // Breakdown
                        VStack(spacing: 8) {
                            XPBreakdownRow(
                                label: "Raw XP", value: "\(Int(breakdown.xpRaw))")
                            XPBreakdownRow(
                                label: "Quality",
                                value: String(format: "x%.1f", breakdown.executionQuality))
                            XPBreakdownRow(
                                label: "Time Bonus",
                                value: String(format: "x%.1f", breakdown.timeMultiplier))
                        }
                    }
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(
                        Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

struct XPBreakdownRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}
