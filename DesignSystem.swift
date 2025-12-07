import SwiftUI

// MARK: - Apple Human Interface Guidelines (Liquid Glass Edition)
enum DesignSystem {
    
    enum Colors {
        // System Backgrounds
        static let background = Color.black
        static let secondaryBackground = Color(uiColor: .systemGray6)
        
        // Liquid Glass Tints (Subtle)
        static let glassTintBlue = Color.blue.opacity(0.1)
        static let glassTintPurple = Color.purple.opacity(0.1)
        
        // Typography Colors
        static let labelPrimary = Color.white
        static let labelSecondary = Color(uiColor: .systemGray)
        static let labelTertiary = Color(uiColor: .systemGray2)
        
        // Semantic Actions
        static let action = Color.blue
        static let destructive = Color.red
        static let success = Color.green
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let standard: CGFloat = 16
        static let lg: CGFloat = 20
        static let section: CGFloat = 24
        static let element: CGFloat = 12
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let container: CGFloat = 24 // iOS 26 Standard Container
        static let element: CGFloat = 16   // Buttons/Inputs
        static let touch: CGFloat = 44     // Touch Targets
    }
}

// Helper for Hex Colors (Legacy Support)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
