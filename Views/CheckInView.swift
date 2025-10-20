//
//  CheckInView.swift
//  POS
//
//  Created by Kyle Lippard on 9/3/25.
//

import SwiftUI


// MARK: CheckInView (The requested view)

// SIDE BAR VIEW (Where the keypad and new buttons are located)
struct CheckInView: View {
    let selectedReason: MenuItem
    var lastQueueMDN: String?
    
    // 1. Inject the shared state and functions
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    
    @State private var string = "Enter MDN"
    @State private var customerName: String? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var searchTask: Task<Void, Never>?
    
    //let onComplete: () -> Void
    
    
    // 2. Helper to get only the digits (ready for DB search)
    var cleanMDN: String {
        string.filter(\.isNumber)
    }
    
    var body: some View {
        VStack {
            Text("CheckIn")
                .font(.title)
            
            Text(selectedReason.name)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            // MDN Input Display Area
            VStack {
                HStack{
                    Spacer()
                    // Display the found customer name, or a default placeholder
                    if showError {
                        Text(errorMessage)
                        // .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }else {
                        Text(customerName ?? "Customer")
                        // .font(.headline)
                            .foregroundColor(customerName == nil ? .gray : .primary)
                            .padding([.leading])
                    }
                    
                }
                .padding(.horizontal)
                Divider()
                
                HStack {
                    Spacer()
                    Text(string)
                    //   .font(.title2)
                        .foregroundColor(string == "Enter MDN" ? .gray : .primary)
                }
                .padding([.leading, .trailing])
                Divider()
                
                // The KeyPad
                KeyPad(string: $string)
            }
            .font(.callout)
            .padding()
            
            Spacer()
            
            // New Buttons Section
            VStack(spacing: 15) {
                // Show loading spinner if searching
                if customerAccountViewModel.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading...")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                // ASSIST BUTTON
                Button(action: {
                    Task {
                        await MainActor.run {
                            customerAccountViewModel.findCustomer(by: cleanMDN)
                        }
                    }
                }) {
                    Text("Assist")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customerName != nil ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(customerName == nil || customerAccountViewModel.isLoading)
                .buttonStyle(.plain)
                
                // ADD TO QUEUE BUTTON
                Button(action: {
                    DispatchQueue.main.async {
                        addToQueue(mdn: cleanMDN, reason: selectedReason.name)
                        
                    }
                }) {
                    Text("Add to Queue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(customerName == nil || customerAccountViewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        //Monitor the MDN string for changes
        .onChange(of: cleanMDN) {
            // Cancel previous search task
            searchTask?.cancel()
            
            if cleanMDN.count == 10 {
                searchTask = Task {
                    // Add small delay to debounce
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    
                    guard !Task.isCancelled else { return }
                    
                    let foundName = await customerAccountViewModel.lookupCustomerName(by: cleanMDN)
                    
                    guard !Task.isCancelled else { return }
                    
                    self.customerName = foundName
                    
                    if foundName == nil {
                        withAnimation {
                            errorMessage = "No customer found with MDN: \(string)"
                            showError = true
                        }
                        Task {
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            withAnimation {
                                showError = false
                            }
                        }
                    } else {
                        withAnimation {
                            showError = false
                        }
                    }
                }
            } else {
                self.customerName = nil
                withAnimation {
                    showError = false
                }
            }
        }
    }
    // Adds customer to in-memory queue (Add to Queue button action).
    func addToQueue(mdn: String, reason: String) {
        // Post notification to update QueueView
        NotificationCenter.default.post(
            name: .customerAddedToQueue,
            object: ["mdn": mdn, "reason": reason]
            
        )
        // Post notification to reset CheckInView
        NotificationCenter.default.post(
            name: .resetCheckIn,
            object: nil
        )
        print("Customer with MDN \(mdn) added to queue for reason: \(reason)")
    }
}

#Preview {
    let mockReason = MenuItem(name: "Upgrade", icon: "arrow.up")
    NavigationView {
        CheckInView(selectedReason: mockReason)
            .environmentObject(CustomerAccountViewModel())
    }
}
