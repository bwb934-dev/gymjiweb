//
//  ContentView.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                .tag(1)
            
            ExerciseListView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Exercises")
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("History")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
}
