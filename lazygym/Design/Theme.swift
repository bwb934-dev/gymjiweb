import SwiftUI

// MARK: - Design System Theme
struct Theme {
    // MARK: - Colors
    struct Colors {
        // Brand accent color
        static let accent = Color("AccentColor")
        
        // System colors (automatically adapt to light/dark)
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        static let separator = Color(.separator)
        
        // Semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Card colors
        static let cardBackground = Color(.systemBackground)
        static let cardSecondary = Color(.secondarySystemBackground)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let card = (radius: CGFloat(8), y: CGFloat(4))
        static let button = (radius: CGFloat(4), y: CGFloat(2))
        static let overlay = (radius: CGFloat(12), y: CGFloat(6))
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}
