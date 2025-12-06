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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background Glow
            Circle()
                .fill(Color.green.opacity(0.1))
                .blur(radius: 150)
                .offset(x: 0, y: -100)

            VStack(spacing: 30) {
                Spacer()

                // Level Up Badge (if leveled up)
                if response.leveledUp {
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

                    Text("+\(response.xpAwarded) XP")
                        .font(.system(size: 60, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                        .scaleEffect(animateXP ? 1.0 : 0.5)
                        .opacity(animateXP ? 1.0 : 0.0)
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

                        Text(response.feedback)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        Divider().background(Color.white.opacity(0.2))

                        // Breakdown
                        VStack(spacing: 8) {
                            XPBreakdownRow(
                                label: "Raw XP", value: "\(Int(response.breakdown.xpRaw))")
                            XPBreakdownRow(
                                label: "Quality",
                                value: String(format: "x%.1f", response.breakdown.executionQuality))
                            XPBreakdownRow(
                                label: "Time Bonus",
                                value: String(format: "x%.1f", response.breakdown.timeMultiplier))
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

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Collect Rewards")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
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
