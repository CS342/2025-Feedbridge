//
//  FeedEntry.swift
//  Feedbridge
//
//  Created by Calvin Xu on 1/30/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
@preconcurrency import FirebaseFirestore
import Foundation

// Represents method of feeding
enum FeedType: String, Codable {
    case directBreastfeeding
    case bottle
}

// Represents the type of milk used
enum MilkType: String, Codable {
    case breastmilk
    case formula
}

/// Stores feeding-related data
struct FeedEntry: Identifiable, Codable, Sendable {
    /// Use UUID to generate a unique identifier for Firebase
    @DocumentID var id: String?

    /// Date and time of the feed
    var dateTime: Date

    /// Type of feeding (direct breastfeeding or bottle)
    var feedType: FeedType

    /// Type of milk used if feedType = .bottle
    var milkType: MilkType?

    /// Duration of direct breastfeeding in minutes
    var feedTimeInMinutes: Int?

    /// Bottle feed volume in milliliters
    var feedVolumeInML: Int?

    /// Initialize for direct breastfeeding
    init(directBreastfeeding minutes: Int, dateTime: Date = Date()) {
        self.dateTime = dateTime
        feedType = .directBreastfeeding
        feedTimeInMinutes = minutes
        milkType = nil
        feedVolumeInML = nil
    }

    /// Initialize for bottle feeding
    init(bottle volumeML: Int, milkType: MilkType, dateTime: Date = Date()) {
        self.dateTime = dateTime
        feedType = .bottle
        self.milkType = milkType
        feedVolumeInML = volumeML
        feedTimeInMinutes = nil
    }
}
