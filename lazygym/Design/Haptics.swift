import UIKit

// MARK: - Haptic Feedback System
struct Haptics {
    // MARK: - Impact Feedback
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Custom Feedback
    static func buttonPress() {
        light()
    }
    
    static func setComplete() {
        medium()
    }
    
    static func workoutComplete() {
        success()
    }
    
    static func workoutStart() {
        heavy()
    }
    
    static func timerComplete() {
        warning()
    }
    
    static func errorOccurred() {
        error()
    }
}
