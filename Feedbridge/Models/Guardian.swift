//
//  Guardian.swift
//  Feedbridge
//
//  Created by Calvin Xu on 1/30/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import Foundation

/// Represents a guardian (parent or caregiver) who takes care of babies
struct Guardian: Identifiable, Codable {
    /// Unique identifier for the guardian
    var id: String = UUID().uuidString
    
    /// Guardian's full name
    var name: String
    
    /// Guardian's email address
    var email: String
    
    /// Guardian's phone number
    var phoneNumber: String
    
    /// Collection of babies under this guardian's care
    var babies: [Baby]
    
    /// Get all babies with active medical alerts
    var babiesWithAlerts: [Baby] {
        babies.filter { $0.hasActiveAlerts }
    }
    
    /// Initialize a new guardian with required information
    init(name: String, email: String, phoneNumber: String) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.babies = []
    }
    
    /// Add a baby to the guardian's care
    mutating func addBaby(_ baby: Baby) {
        babies.append(baby)
    }
    
    /// Remove a baby from the guardian's care
    mutating func removeBaby(withId id: String) {
        babies.removeAll { $0.id == id }
    }
}
