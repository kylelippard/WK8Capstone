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

Installation

Clone the repository:

