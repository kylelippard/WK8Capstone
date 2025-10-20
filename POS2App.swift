//
//  POS2App.swift
//  POS2
//
//  Created by Kyle Lippard on 10/4/25.
//

import SwiftUI

@main
struct POS2App: App {
    @StateObject private var customerAccountViewModel = CustomerAccountViewModel()
    @State private var isDatabaseReady = false
    
    var body: some Scene {
        WindowGroup {
            if isDatabaseReady {
                ContentView()
                    .environmentObject(customerAccountViewModel)
            } else {
                ProgressView("Initializing...")
                    .task {
                        do {
                            try await DatabaseManager.shared.initialize()
                            isDatabaseReady = true
                        } catch {
                            print("❌ Failed to initialize database: \(error)")
                            // Handle the error appropriately
                            // You might want to show an error view here
                        }
                    }
            }
        }
    }
}
