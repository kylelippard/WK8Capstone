//
//  AccountOverviewView.swift
//  POS
//
//  Created by Kyle Lippard on 9/9/25.
//

import SwiftUI

// MARK: Account Overview View (The main screen)

// The main view displaying the list of account lines using LineView.
struct AccountOverviewView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    
    var body: some View {
        if customerAccountViewModel.isLoading {
            VStack {
                ProgressView("Loading account...")
                    .scaleEffect(1.5)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let customer = customerAccountViewModel.currentCustomer {
            List {
                Section(header: Text("Account: \(customer.name)").font(.title3.bold())) {
                    if let accountNum = customer.account_number {
                        Text("Account Number: \(String(accountNum))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Lines").font(.title3.bold())) {
                    if customerAccountViewModel.currentLines.isEmpty {
                        Text("No lines found for this account")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(customerAccountViewModel.currentLines, id: \.mdn) { line in
                            LineView(line: line)
                        }
                        .drawingGroup() 
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "No Customer Selected",
                systemImage: "person.fill.questionmark",
                description: Text("Check in a customer to view their account")
            )
        }
    }
}

#Preview {
    NavigationStack {
        AccountOverviewView()
            .environmentObject(DummyData.createMockViewModel())
    }
}
