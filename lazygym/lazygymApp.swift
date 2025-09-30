//
//  lazygymApp.swift
//  lazygym
//
//  Created by Budr Albakri on 27.09.25.
//

import SwiftUI

@main
struct lazygymApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    print("🚀 LazyGym App launched")
                }
        }
    }
}
