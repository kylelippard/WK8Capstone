//
//  MenuViewModel.swift
//  POS
//
//  Created by Kyle Lippard on 9/21/25.
//

import Foundation
import Combine

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var items: [MenuItem]?
    
    // Sales menu items
    static let upgrade = MenuItem(name: "Upgrade", icon: "arrow.up")
    static let addAline = MenuItem(name: "Add A Line", icon: "plus")
    static let accessory = MenuItem(name: "Accessory", icon: "shippingbox")
    
    //Billing menu items
    static let billingQuestion = MenuItem(name: "Billing Question", icon: "doc.text.magnifyingglass")
    static let payBill = MenuItem(name: "Pay a Bill", icon: "dollarsign")
    
    //Trade menu items
    static let tradeReturn = MenuItem(name: "Trade in Return", icon: "pip.swap")
    static let equipReturn = MenuItem(name: "Return Equipment", icon: "wifi.router")
    
    // some example groups
    static let example1 = MenuItem(name: "Sales", icon: "cart", items: [MenuItem.upgrade, MenuItem.addAline, MenuItem.accessory])
    static let example2 = MenuItem(name: "Billing", icon: "doc", items: [MenuItem.billingQuestion, MenuItem.payBill])
    static let example3 = MenuItem(name: "Trade In or Return", icon: "rectangle.2.swap", items: [MenuItem.tradeReturn, MenuItem.equipReturn])
}


class MenuViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []

    init() {
        // Your menu data setup
        let salesGroup = MenuItem(name: "Sales", icon: "cart", items: [
            MenuItem.upgrade, MenuItem.addAline, MenuItem.accessory
        ])
        let billingGroup = MenuItem(name: "Billing", icon: "doc", items: [
            MenuItem.billingQuestion, MenuItem.payBill
        ])
        let tradeGroup = MenuItem(name: "Trade In or Return", icon: "rectangle.2.swap", items: [
            MenuItem.tradeReturn, MenuItem.equipReturn
        ])
        self.menuItems = [salesGroup, billingGroup, tradeGroup]
    }
}
