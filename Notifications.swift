//
//  Notifications.swift
//  POS
//
//  Created by Kyle Lippard on 10/2/25.
//

import Foundation

extension Notification.Name {
    static let customerAddedToQueue = Notification.Name("customerAddedToQueue")
    static let queueItemSelected = Notification.Name("queueItemSelected")
    static let resetCheckIn = Notification.Name("resetCheckIn")
    static let reasonSelected = Notification.Name("reasonSelected") 
}
