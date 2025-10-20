POS System

A modern Point of Sale system built with SwiftUI and GRDB for managing wireless service customers, lines, and device inventory.
Features
📱 Customer Management

Create and manage customer profiles
Store customer information (name, contact details, address, etc.)
Search customers by name or phone number
View customer account details and lines

📞 Line Management

Add and manage service lines for customers
Assign devices (IMEI) to lines
Track line plans and features
View line status and activation dates
Edit device and plan assignments

📦 Device Inventory

Track devices by IMEI
Monitor device availability
Automatic IMEI assignment from available inventory
Device status tracking (available/assigned)

🛒 Device Shop

Browse available devices for sale
Search devices by name
View device pricing and images
Select devices with automatic IMEI assignment
Supports iPhone, Samsung, and other device types

Tech Stack

Swift - Primary programming language
SwiftUI - UI framework
GRDB - SQLite database wrapper
Swift Concurrency - Async/await patterns
Actor Isolation - Thread-safe database operations

Database Structure
Tables
customers

Customer personal information
Contact details
Address information
Created timestamp

lines

Service line details
MDN (Mobile Directory Number)
Associated customer ID
Device IMEI assignment
Plan and features (JSON)
Status and activation date

devices

Device inventory
IMEI tracking
Device model information
ICCID and condition
Purchase date

devices_for_sale

Devices available for purchase
Device name and pricing
Image URLs
Availability status

Setup
Requirements

iOS 17.0+
Xcode 15.0+
Swift 5.9+

IMEI Availability System
Devices are automatically tracked based on assignment to lines:

Unassigned IMEIs are available for selection
Assigned IMEIs are filtered out
No status column needed - assignment determines availability

Contributing

Fork the repository
Create a feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request

License
This project is licensed under the MIT License - see the LICENSE file for details.
Acknowledgments

GRDB.swift for excellent SQLite wrapper
SwiftUI for modern iOS UI development
Apple's Swift Concurrency for safe async operations

