import SwiftUI

// MARK: - Modern Tab Bar (Native Floating Pill)
struct ModernTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs = [
        (icon: "house.fill", index: 0),
        (icon: "person.fill", index: 1)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                Button(action: {
                    withAnimation(.snappy) { selectedTab = tab.index }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                        
                        // Active Dot Indicator
                        if selectedTab == tab.index {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 4, height: 4)
                                .matchedGeometryEffect(id: "tab_dot", in: namespace)
                        } else {
                            Circle().fill(.clear).frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(selectedTab == tab.index ? .white : .secondary)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        // Hier nutzen wir die neue API
        .glassEffect(material: .ultraThinMaterial, radius: 100)
        .padding(.horizontal, 32)
    }
    
    @Namespace private var namespace
}

// MARK: - Liquid Glass Card (Native Feel)
struct LiquidGlassCard<Content: View>: View {
    var content: Content
    var padding: CGFloat
    
    init(padding: CGFloat = DesignSystem.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background {
                // Layering für den perfekten Glas-Look
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial) // Basis Blur
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.03)) // Specular Highlight
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
            // Kein Border mehr, oder extrem subtil
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

// MARK: - Ambient Glow Background (Organic)
struct AmbientGlowBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Moving Aurora Background
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                
                ZStack {
                    Circle().fill(Color.blue.opacity(0.2)).blur(radius: 100)
                        .frame(width: w, height: w)
                        .position(x: w*0.2, y: h*0.2)
                    
                    Circle().fill(Color.purple.opacity(0.2)).blur(radius: 100)
                        .frame(width: w*0.8, height: w*0.8)
                        .position(x: w*0.8, y: h*0.6)
                    
                    Circle().fill(Color.cyan.opacity(0.15)).blur(radius: 80)
                        .frame(width: w*0.6, height: w*0.6)
                        .position(x: w*0.5, y: h*0.9)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Hunter Stat Badge (Apple Fitness Style)
struct HunterStatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .glassEffect(material: .ultraThinMaterial, radius: 16)
    }
}

// MARK: - Official Liquid Glass API Implementation

/// Simuliert die iOS 26 .glassEffect() API
struct LiquidGlassModifier: ViewModifier {
    var style: Material
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // 1. The Material (Blur)
                    Rectangle()
                        .fill(style)
                    
                    // 2. The "Liquid" Sheen (Specular Highlight)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.07), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                // 3. The Rim Light (Subtle Border)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

extension View {
    /// Wendet den offiziellen Liquid Glass Effekt an.
    /// - Parameters:
    ///   - material: Das Material (Standard: .ultraThinMaterial)
    ///   - radius: Der Eckenradius (Standard: 24)
    func glassEffect(material: Material = .ultraThinMaterial, radius: CGFloat = DesignSystem.Radius.container) -> some View {
        self.modifier(LiquidGlassModifier(style: material, cornerRadius: radius))
    }
}

/// Container für gruppierte Glass-Elemente (iOS 26 Style)
struct GlassEffectContainer<Content: View>: View {
    var spacing: CGFloat = DesignSystem.Spacing.standard
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(spacing: spacing) {
            content()
        }
        .padding(DesignSystem.Spacing.standard)
        .glassEffect(material: .regularMaterial, radius: DesignSystem.Radius.container)
    }
}
