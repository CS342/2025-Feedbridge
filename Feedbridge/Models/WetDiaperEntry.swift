//
//  WetDiaperEntry.swift
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

// Represents diaper volume classifications
enum DiaperVolume: String, Codable {
    case light
    case medium
    case heavy
}

// Represents color variations for wet diaper entries
enum WetDiaperColor: String, Codable {
    case yellow
    case pink
    case redTinged
}

/// Stores wet diaper data
struct WetDiaperEntry: Identifiable, Codable, Sendable {
    @DocumentID var id: String?

    /// Date and time of the diaper event
    var dateTime: Date

    /// Volume classification
    var volume: DiaperVolume

    /// Color of the diaper
    var color: WetDiaperColor

    /// Whether an alert has been triggered
    var dehydrationAlert: Bool {
        color == .pink || color == .redTinged
    }
}
