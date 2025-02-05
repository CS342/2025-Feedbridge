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

import FirebaseFirestore

// Represents a guardian (parent or caregiver) who takes care of babies
// periphery:ignore
struct Guardian: Identifiable, Codable {
    /// Unique identifier for the guardian
    @DocumentID var id: String?

    /// Guardian's full name
    var name: String

    /// Guardian's email address
    var email: String

    /// Collection of babies under this guardian's care
    var babies: [Baby]

    /// Get all babies with active medical alerts
    var babiesWithAlerts: [Baby] {
        babies.filter(\.hasActiveAlerts)
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
