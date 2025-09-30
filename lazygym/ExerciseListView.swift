//
//  ExerciseListView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct ExerciseListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExercise = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.exercises) { exercise in
                    ExerciseRowView(exercise: exercise)
                }
                .onDelete(perform: deleteExercises)
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExercise = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
    
    private func deleteExercises(offsets: IndexSet) {
        for index in offsets {
            let exercise = dataManager.exercises[index]
            dataManager.deleteExercise(exercise)
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    @EnvironmentObject var dataManager: DataManager
    @State private var showingEditExercise = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(exercise.progressionType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(progressionColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text(exercise.isUpperBody ? "Upper Body" : "Lower Body")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if exercise.currentWeight > 0 {
                    Text("Current Weight: \(String(format: "%.1f", exercise.currentWeight)) kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if exercise.progressionType == .pyramid {
                    Text("Base Reps: \(exercise.baseReps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingEditExercise = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditExercise) {
            EditExerciseView(exercise: exercise)
        }
    }
    
    private var progressionColor: Color {
        switch exercise.progressionType {
        case .amrap:
            return .blue
        case .pyramid:
            return .green
        case .free:
            return .orange
        }
    }
}

#Preview {
    ExerciseListView()
        .environmentObject(DataManager.shared)
}
