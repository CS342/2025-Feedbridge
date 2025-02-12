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
// swiftlint:disable file_types_order

@preconcurrency import FirebaseFirestore
import Foundation

// periphery:ignore
/// Represents a baby and their associated health tracking data
struct Baby: Identifiable, Codable, Sendable {
    /// Unique identifier for the baby
    @DocumentID var id: String?

    /// Baby's full name
    var name: String

    /// Baby's date of birth
    var dateOfBirth: Date

    /// Collection of all feeding records
    var feedEntries: FeedEntries

    /// Collection of all weight measurements
    var weightEntries: WeightEntries

    /// Collection of all stool records
    var stoolEntries: StoolEntries

    /// Collection of all wet diaper records
    var wetDiaperEntries: WetDiaperEntries

    /// Collection of all dehydration check records
    var dehydrationChecks: DehydrationChecks

    /// Calculate baby's age in months (rounded down)
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }

    /// Get the most recent weight entry
    var currentWeight: WeightEntry? {
        weightEntries.weightEntries.max(by: { $0.dateTime < $1.dateTime })
    }

    /// Get the most recent dehydration check
    var latestDehydrationCheck: DehydrationCheck? {
        dehydrationChecks.dehydrationChecks.max(by: { $0.dateTime < $1.dateTime })
    }

    /// Check if there are any active medical alerts
    var hasActiveAlerts: Bool {
        latestDehydrationCheck?.dehydrationAlert == true
            || wetDiaperEntries.wetDiaperEntries.last?.dehydrationAlert == true
            || stoolEntries.stoolEntries.last?.medicalAlert == true
    }

    init(name: String, dateOfBirth: Date) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.feedEntries = FeedEntries(feedEntries: [])
        self.weightEntries = WeightEntries(weightEntries: [])
        self.stoolEntries = StoolEntries(stoolEntries: [])
        self.wetDiaperEntries = WetDiaperEntries(wetDiaperEntries: [])
        self.dehydrationChecks = DehydrationChecks(dehydrationChecks: [])
    }
}

struct FeedEntries: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var feedEntries: [FeedEntry]
}

struct WeightEntries: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var weightEntries: [WeightEntry]
}

struct StoolEntries: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var stoolEntries: [StoolEntry]
}

struct WetDiaperEntries: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var wetDiaperEntries: [WetDiaperEntry]
}

struct DehydrationChecks: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var dehydrationChecks: [DehydrationCheck]
}
