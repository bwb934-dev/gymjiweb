import SwiftUI

// MARK: - Card Component
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: .black.opacity(0.1),
                radius: Theme.Shadow.card.radius,
                y: Theme.Shadow.card.y
            )
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.TextStyles.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.md)
            .background(
                isEnabled ? Theme.Colors.accent : Theme.Colors.separator
            )
            .cornerRadius(Theme.CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.TextStyles.button)
            .foregroundColor(Theme.Colors.accent)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.accent.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Theme.Colors.accent, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .sectionHeader()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
    }
}

// MARK: - Chip Component
struct Chip: View {
    let text: String
    let color: Color
    let isSelected: Bool
    
    init(_ text: String, color: Color = Theme.Colors.accent, isSelected: Bool = false) {
        self.text = text
        self.color = color
        self.isSelected = isSelected
    }
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                isSelected ? color : color.opacity(0.1)
            )
            .cornerRadius(Theme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        Card {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(title)
                        .secondaryText()
                    
                    Text(value)
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Timer Display Component
struct TimerDisplay: View {
    let time: TimeInterval
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(Theme.Colors.secondary)
            
            Text(formatTime(time))
                .timerText()
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.sm)
        .opacity(isActive ? 1.0 : 0.6)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Reps Counter Component
struct RepsCounter: View {
    @Binding var reps: Int
    let minReps: Int
    let maxReps: Int
    
    init(reps: Binding<Int>, minReps: Int = 0, maxReps: Int = 100) {
        self._reps = reps
        self.minReps = minReps
        self.maxReps = maxReps
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Button(action: {
                if reps > minReps {
                    reps -= 1
                    Haptics.light()
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
                    .foregroundColor(reps > minReps ? Theme.Colors.error : Theme.Colors.separator)
            }
            .disabled(reps <= minReps)
            
            Text("\(reps)")
                .repsText()
                .frame(minWidth: 60)
            
            Button(action: {
                if reps < maxReps {
                    reps += 1
                    Haptics.light()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(reps < maxReps ? Theme.Colors.success : Theme.Colors.separator)
            }
            .disabled(reps >= maxReps)
        }
        .animation(Theme.Animation.quick, value: reps)
    }
}

// MARK: - Progress Indicator Component
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    let color: Color
    
    init(current: Int, total: Int, color: Color = Theme.Colors.accent) {
        self.current = current
        self.total = total
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            HStack {
                Text("\(current) of \(total)")
                    .captionText()
                
                Spacer()
                
                Text("\(Int(Double(current) / Double(total) * 100))%")
                    .captionText()
            }
            
            ProgressView(value: Double(current), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
    }
}

// MARK: - Weight Picker Component
struct WeightPicker: View {
    @Binding var weight: Double
    
    private let weightRange = Array(stride(from: 0.0, through: 200.0, by: 0.5))
    
    init(weight: Binding<Double>) {
        self._weight = weight
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Working Weight Label
            HStack {
                Text("Working Weight")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.primary)
                
                Spacer()
                
                Text("kg")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.secondary)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            
            // Compact Picker Wheel
            GeometryReader { geometry in
                ZStack {
                    // Background gradient to fade edges
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.background,
                            Theme.Colors.background.opacity(0.8),
                            Theme.Colors.background.opacity(0.0),
                            Theme.Colors.background.opacity(0.0),
                            Theme.Colors.background.opacity(0.8),
                            Theme.Colors.background
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                    
                    // Picker - directly bound to weight
                    Picker("Weight", selection: $weight) {
                        ForEach(weightRange, id: \.self) { weightValue in
                            Text(String(format: "%.1f", weightValue))
                                .font(.system(.largeTitle, design: .monospaced).weight(.bold))
                                .foregroundColor(Theme.Colors.accent)
                                .padding(.vertical, Theme.Spacing.sm)
                                .tag(weightValue)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: weight) {
                        print("🔍 WeightPicker onChange: \(weight)kg")
                        Haptics.selection()
                    }
                }
            }
            .frame(height: 100)
            .clipped()
        }
    }
}
