//
//  WorkoutListView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.workoutTemplates) { template in
                    WorkoutRowView(template: template)
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView()
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        for index in offsets {
            let template = dataManager.workoutTemplates[index]
            dataManager.deleteWorkoutTemplate(template)
        }
    }
}

struct WorkoutRowView: View {
    let template: WorkoutTemplate
    @EnvironmentObject var dataManager: DataManager
    @State private var showingEditWorkout = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingEditWorkout = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            Text("\(template.currentExercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Exercise preview
            if !template.currentExercises.isEmpty {
                HStack {
                    ForEach(template.currentExercises.prefix(3)) { workoutExercise in
                        Text(workoutExercise.exercise.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    if template.exercises.count > 3 {
                        Text("+\(template.exercises.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditWorkout) {
            EditWorkoutView(template: template)
        }
    }
}

#Preview {
    WorkoutListView()
        .environmentObject(DataManager.shared)
}
