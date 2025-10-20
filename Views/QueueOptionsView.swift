//
//  QueueOptionsView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/7/25.
//

import SwiftUI

struct QueueOptionsView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    @ObservedObject var queueManager = QueueManager.shared
    let queueItem: QueueItem
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Back button
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .padding()
                Spacer()
            }
            
            // Loading indicator
            if customerAccountViewModel.isLoading {
                ProgressView("Loading account...")
                    .scaleEffect(1.3)
                    .padding()
            }
            
            Spacer()
            
            // Customer info
            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text(queueItem.customer.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let accountNum = queueItem.customer.account_number {
                    Text("Account: \(accountNum)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Reason: \(queueItem.reason)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Wait Time: \(queueItem.waitTime)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button {
                    Task {
                        await customerAccountViewModel.loadCustomerAccount(queueItem.customer)
                        onBack()
                    }
                    // Close the options view
                    
                } label: {
                    Label("Assist Customer", systemImage: "person.fill.checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    queueManager.removeFromQueue(item: queueItem)
                    onBack()
                } label: {
                    Label("Remove from Queue", systemImage: "trash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(CustomerAccountViewModel())
    
}
