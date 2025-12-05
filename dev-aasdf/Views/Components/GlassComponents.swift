//
//  GlassComponents.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import SwiftUI

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Ultra Thin Material for the glass effect
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)

                    // Subtle gradient overlay for depth
                    LinearGradient(
                        colors: [
                            .white.opacity(0.1),
                            .white.opacity(0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Stat Card View

struct StatCardView: View {
    let title: String
    let value: String
    var accentColor: Color = .white
    var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1)

            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
            } else {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(accentColor)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .glassCard(cornerRadius: 16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 12) {
            StatCardView(title: "Strength", value: "67", accentColor: .blue)
            StatCardView(title: "Intel", value: "—")
        }
        .padding()
    }
}
