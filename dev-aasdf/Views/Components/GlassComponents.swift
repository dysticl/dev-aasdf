//
//  GlassComponents.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import SwiftUI

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
        .glassCard(cornerRadius: 16, strokeColor: Color.white, strokeOpacity: 0.12)
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
