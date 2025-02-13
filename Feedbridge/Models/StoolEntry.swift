//
//  StoolEntry.swift
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

// Represents stool volume classifications
// periphery:ignore
enum StoolVolume: String, Codable {
    case light
    case medium
    case heavy
}

/// Represents color variations for stool entries
enum StoolColor: String, Codable {
    case black
    case darkGreen
    case green
    case brown
    case yellow
    case beige
}

/// Stores stool data
struct StoolEntry: Identifiable, Codable, Sendable {
    @DocumentID var id: String?

    /// Date and time of the stool event
    var dateTime: Date

    /// Volume classification
    var volume: StoolVolume

    /// Color of the stool
    var color: StoolColor

    /// Whether a medical alert should be displayed
    var medicalAlert: Bool {
        color == .beige
    }
}
