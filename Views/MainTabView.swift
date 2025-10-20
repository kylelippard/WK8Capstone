//
//  MainTabView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/5/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var queueManager = QueueManager.shared
    @StateObject private var customerAccountViewModel = CustomerAccountViewModel()
    
    @State private var isInitialized = false
    @State private var initializationError: Error?
    
    @State private var currentView: MainViewState = .home
    @State private var selectedReason: MenuItem?
    @State private var selectedQueueItem: QueueItem?
    
    
    var body: some View {
        ZStack {
            if isInitialized {
                mainContent
                    .environmentObject(customerAccountViewModel)
                    .environmentObject(queueManager)
            } else if let error = initializationError {
                // Error state
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Failed to initialize database")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        initializationError = nil
                        Task {
                            await initializeApp()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Loading state
                VStack(spacing: 20) {
                    Image("verizon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Initializing application...")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
        .task {
            await initializeApp()
        }
        .onChange(of: customerAccountViewModel.isAccountFound) { _, newValue in
            if newValue == true {
                selectedReason = nil
                selectedQueueItem = nil
                currentView = .account
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .queueItemSelected)) { notification in
            if let queueItem = notification.object as? QueueItem {
                selectedQueueItem = queueItem
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetCheckIn)) { _ in  // ← Add this
            selectedReason = nil
            selectedQueueItem = nil
            currentView = .home
        }
        .onReceive(NotificationCenter.default.publisher(for: .reasonSelected)) { notification in
            if let reason = notification.object as? MenuItem {
                selectedReason = reason
            }
        }
    }
    
    private func initializeApp() async {
        let start = CFAbsoluteTimeGetCurrent()
        
        do {
            // Initialize database off the main thread
            try await DatabaseManager.shared.initialize()
            
            let duration = CFAbsoluteTimeGetCurrent() - start
            print("⏱️ Total app initialization: \(String(format: "%.3f", duration))s")
            
            // Update UI on main thread
            await MainActor.run {
                isInitialized = true
            }
        } catch {
            print("❌ Failed to initialize app: \(error)")
            await MainActor.run {
                initializationError = error
            }
        }
    }
    
    private var mainContent: some View {
        VStack {
            // Top tab bar
            HStack(spacing: 20) {
                Image("verizon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .padding(.leading)
                
                Spacer()
                
                Button {
                    currentView = .home
                    selectedReason = nil
                    selectedQueueItem = nil
                    customerAccountViewModel.isAccountFound = false
                } label: {
                    Label("Home", systemImage: "house.fill")
                }
                
                Button {
                    if customerAccountViewModel.currentCustomer != nil {
                        currentView = .account
                    }
                } label: {
                    Label("Account", systemImage: "person.fill")
                }
                .disabled(customerAccountViewModel.currentCustomer == nil)
                .opacity(customerAccountViewModel.currentCustomer == nil ? 0.5 : 1.0)
                
                Button {
                    if customerAccountViewModel.currentCustomer != nil {
                        currentView = .order
                    }
                } label: {
                    Label("Order", systemImage: "cart.fill")
                }
                .disabled(customerAccountViewModel.currentCustomer == nil)
                .opacity(customerAccountViewModel.currentCustomer == nil ? 0.5 : 1.0)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            
            // Main content area
            GeometryReader { geometry in
                switch currentView {
                case .home:
                    HStack(spacing: 0) {
                        VStack {
                            if let queueItem = selectedQueueItem {
                                QueueOptionsView(queueItem: queueItem) {
                                    selectedQueueItem = nil
                                }
                            } else if let reason = selectedReason {
                                HStack {
                                    Button {
                                        selectedReason = nil
                                        customerAccountViewModel.isAccountFound = false
                                    } label: {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                            Text("Back")
                                        }
                                    }
                                    .padding()
                                    Spacer()
                                }
                                CheckInView(selectedReason: reason)
                                    .id(reason.id)
                            } else {
                                ReasonForVisitView()
                            }
                        }
                        .frame(width: geometry.size.width * 0.3)
                        
                        Divider()
                        
                        QueueView()
                            .frame(width: geometry.size.width * 0.7)
                    }
                    
                case .account:
                    NavigationStack{
                        AccountOverviewView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                case .order:
                    OrderTabView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

enum MainViewState {
    case home
    case account
    case order
}

#Preview {
    MainTabView()
        .environmentObject(DummyData.createMockViewModel())
}
