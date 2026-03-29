//
//  BetterBarterApp.swift
//  BetterBarter
//
//  Created by Shailesh on 17/03/26.
//

import SwiftUI
import FirebaseCore

// MARK: - Main App Entry Point

@main
struct BetterBarterApp: App {
    
    init() {
        // Initialize Firebase FIRST, before any Firebase service is accessed
        FirebaseApp.configure()
        print("✅ Firebase Configured Successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            
            RootView()
                .environmentObject(AppState.shared)
                .environment(AuthService.shared)
        }
    }
}
