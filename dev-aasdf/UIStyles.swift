import SwiftUI

// Reusable Liquid Glass card/background helpers to keep a single glass container per element
public struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let strokeColor: Color?
    let strokeOpacity: Double
    let padding: CGFloat?

    public func body(content: Content) -> some View {
        let base = content
            .padding(padding ?? 0)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            )
            .overlay(
                Group {
                    if let strokeColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(strokeColor.opacity(strokeOpacity), lineWidth: 1)
                    }
                }
            )
        return base
    }
}

public extension View {
    /// Apply a single, standardized Liquid Glass card container to avoid double-stacking materials
    func glassCard(cornerRadius: CGFloat = 16,
                   strokeColor: Color? = Color.white,
                   strokeOpacity: Double = 0.12,
                   padding: CGFloat? = nil) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius,
                           strokeColor: strokeColor,
                           strokeOpacity: strokeOpacity,
                           padding: padding))
    }

    /// A compact chip/pill style with glass effect
    func glassChip() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.clear)
                    .glassEffect(.regular, in: .capsule)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}
