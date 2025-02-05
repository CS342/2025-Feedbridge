//
//  Baby.swift
//  Feedbridge
//
//  Created by Calvin Xu on 1/30/25.
//
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import FirebaseFirestore
import Foundation

// periphery:ignore
/// Represents a baby and their associated health tracking data
struct Baby: Identifiable, Codable {
    /// Unique identifier for the baby
    @DocumentID var id: String?

    /// Baby's full name
    var name: String

    /// Baby's date of birth
    var dateOfBirth: Date

    /// Collection of all feeding records
    var feedEntries: [FeedEntry]

    /// Collection of all weight measurements
    var weightEntries: [WeightEntry]

    /// Collection of all stool records
    var stoolEntries: [StoolEntry]

    /// Collection of all wet diaper records
    var wetDiaperEntries: [WetDiaperEntry]

    /// Collection of all dehydration check records
    var dehydrationChecks: [DehydrationCheck]

    /// Calculate baby's age in months (rounded down)
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }

    /// Get the most recent weight entry
    var currentWeight: WeightEntry? {
        weightEntries.max(by: { $0.dateTime < $1.dateTime })
    }

    /// Get the most recent dehydration check
    var latestDehydrationCheck: DehydrationCheck? {
        dehydrationChecks.max(by: { $0.dateTime < $1.dateTime })
    }

    /// Check if there are any active medical alerts
    var hasActiveAlerts: Bool {
        latestDehydrationCheck?.dehydrationAlert == true
            || wetDiaperEntries.last?.dehydrationAlert == true
            || stoolEntries.last?.medicalAlert == true
    }

    /// Initialize a new baby with required information
    init(name: String, dateOfBirth: Date) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        feedEntries = []
        weightEntries = []
        stoolEntries = []
        wetDiaperEntries = []
        dehydrationChecks = []
    }
}
