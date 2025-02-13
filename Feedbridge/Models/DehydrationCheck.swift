//
//  DehydrationCheck.swift
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

/// Stores dehydration-related information
struct DehydrationCheck: Identifiable, Codable, Sendable {
    @DocumentID var id: String?

    /// Date and time of the check
    var dateTime: Date

    /// True if skin elasticity is reduced (e.g., "tenting" over abdomen)
    var poorSkinElasticity: Bool

    /// True if lips or tongue are dry
    var dryMucousMembranes: Bool

    /// Whether a medical alert has been triggered
    var dehydrationAlert: Bool {
        poorSkinElasticity || dryMucousMembranes
    }
}
