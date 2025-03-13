//
//  DateFormatter.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/6/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

// MARK: - Standalone Date Utility Functions

/// Converts a Date object into a "YYYY-MM-DD" formatted string.
/// Example: "2025-03-06"
/// - Parameter date: The date to be formatted.
/// - Returns: A string representation of the date in "YYYY-MM-DD" format.
func dateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
