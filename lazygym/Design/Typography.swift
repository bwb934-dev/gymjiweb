import SwiftUI

// MARK: - Typography System
struct Typography {
    // MARK: - Font Styles
    struct Fonts {
        // Headers
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // Body text
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
        
        // Specialized
        static let button = Font.headline.weight(.semibold)
        static let cardTitle = Font.title3.weight(.semibold)
        static let cardSubtitle = Font.subheadline.weight(.medium)
        
        // Monospaced for numbers
        static let timer = Font.system(.title2, design: .monospaced).weight(.semibold)
        static let weight = Font.system(.title3, design: .monospaced).weight(.medium)
        static let reps = Font.system(.largeTitle, design: .monospaced).weight(.bold)
    }
    
    // MARK: - Text Styles
    struct TextStyles {
        // Screen titles
        static let screenTitle = Fonts.largeTitle
        
        // Section headers
        static let sectionHeader = Fonts.title2
        
        // Card titles
        static let cardTitle = Fonts.cardTitle
        
        // Card subtitles
        static let cardSubtitle = Fonts.cardSubtitle
        
        // Body text
        static let body = Fonts.body
        
        // Secondary text
        static let secondary = Fonts.subheadline
        
        // Caption text
        static let caption = Fonts.caption
        
        // Button text
        static let button = Fonts.button
        
        // Timer display
        static let timer = Fonts.timer
        
        // Weight display
        static let weight = Fonts.weight
        
        // Reps display
        static let reps = Fonts.reps
    }
}

// MARK: - Text Style Extensions
extension Text {
    func screenTitle() -> some View {
        self.font(Typography.TextStyles.screenTitle)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func sectionHeader() -> some View {
        self.font(Typography.TextStyles.sectionHeader)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func cardTitle() -> some View {
        self.font(Typography.TextStyles.cardTitle)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func cardSubtitle() -> some View {
        self.font(Typography.TextStyles.cardSubtitle)
            .foregroundColor(Theme.Colors.secondary)
    }
    
    func bodyText() -> some View {
        self.font(Typography.TextStyles.body)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func secondaryText() -> some View {
        self.font(Typography.TextStyles.secondary)
            .foregroundColor(Theme.Colors.secondary)
    }
    
    func captionText() -> some View {
        self.font(Typography.TextStyles.caption)
            .foregroundColor(Theme.Colors.secondary)
    }
    
    func buttonText() -> some View {
        self.font(Typography.TextStyles.button)
    }
    
    func timerText() -> some View {
        self.font(Typography.TextStyles.timer)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func weightText() -> some View {
        self.font(Typography.TextStyles.weight)
            .foregroundColor(Theme.Colors.primary)
    }
    
    func repsText() -> some View {
        self.font(Typography.TextStyles.reps)
            .foregroundColor(Theme.Colors.primary)
    }
}