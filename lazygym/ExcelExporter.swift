//
//  ExcelExporter.swift
//  lazygym
//
//  Created by Budr Albakri on 28.09.25.
//

import Foundation
import SwiftUI

struct ExcelExporter {
    
    // MARK: - Export Workout History to Excel
    static func exportWorkoutHistory(_ sessions: [WorkoutSession]) -> URL? {
        guard !sessions.isEmpty else { return nil }
        
        // Sort sessions by date (oldest first for better readability)
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        
        // Get all unique exercises across all sessions
        let allExercises = getAllUniqueExercises(from: sortedSessions)
        
        // Create CSV content (we'll save as .xlsx but use CSV format for simplicity)
        var csvContent = ""
        
        // Header row: Date, Exercise1, Exercise2, etc.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        csvContent += "Exercise"
        for session in sortedSessions {
            csvContent += ",\(dateFormatter.string(from: session.startTime))"
        }
        csvContent += "\n"
        
        // Data rows: each exercise with its performance across sessions
        for exercise in allExercises {
            csvContent += exercise.name
            
            for session in sortedSessions {
                let performance = getExercisePerformance(exercise: exercise, in: session)
                csvContent += ",\(performance)"
            }
            csvContent += "\n"
        }
        
        // Save to temporary file
        return saveToFile(content: csvContent, filename: "workout_history.xlsx")
    }
    
    // MARK: - Helper Methods
    
    private static func getAllUniqueExercises(from sessions: [WorkoutSession]) -> [Exercise] {
        var uniqueExercises: [Exercise] = []
        var seenExerciseIds: Set<UUID> = []
        
        for session in sessions {
            for workoutExercise in session.template.currentExercises {
                if !seenExerciseIds.contains(workoutExercise.exercise.id) {
                    uniqueExercises.append(workoutExercise.exercise)
                    seenExerciseIds.insert(workoutExercise.exercise.id)
                }
            }
        }
        
        return uniqueExercises.sorted { $0.name < $1.name }
    }
    
    private static func getExercisePerformance(exercise: Exercise, in session: WorkoutSession) -> String {
        // Find the exercise in this session
        guard let workoutExercise = session.template.currentExercises.first(where: { $0.exercise.id == exercise.id }) else {
            return "" // Exercise not performed in this session
        }
        
        let completedSets = workoutExercise.sets.filter { $0.isCompleted }
        
        guard !completedSets.isEmpty else {
            return "" // No completed sets
        }
        
        switch exercise.progressionType {
        case .amrap:
            // For AMRAP: show working weight + last set reps
            if let lastSet = completedSets.last,
               let actualReps = lastSet.actualReps {
                return "\(String(format: "%.1f", lastSet.weight))kg, reps=\(actualReps)"
            }
            return ""
            
        case .pyramid:
            // For Pyramid: show working weight + all set reps
            let repsString = completedSets.compactMap { $0.actualReps }.map(String.init).joined(separator: ",")
            if let firstSet = completedSets.first {
                return "\(String(format: "%.1f", firstSet.weight))kg, reps=\(repsString)"
            }
            return ""
            
        case .free:
            // For Free: show working weight + last set reps (same as AMRAP)
            if let lastSet = completedSets.last,
               let actualReps = lastSet.actualReps {
                return "\(String(format: "%.1f", lastSet.weight))kg, reps=\(actualReps)"
            }
            return ""
        }
    }
    
    private static func saveToFile(content: String, filename: String) -> URL? {
        // Try to save to Documents directory first (accessible via Files app)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ File saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Error saving to Documents: \(error)")
            
            // Fallback to temporary directory
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(filename)
            
            do {
                try content.write(to: tempFileURL, atomically: true, encoding: .utf8)
                print("✅ File saved to temp: \(tempFileURL.path)")
                return tempFileURL
            } catch {
                print("❌ Error saving to temp: \(error)")
                return nil
            }
        }
    }
}

// MARK: - Share Sheet Support
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
        
        // Configure for better file sharing
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .postToTwitter,
            .postToFacebook,
            .openInIBooks
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
