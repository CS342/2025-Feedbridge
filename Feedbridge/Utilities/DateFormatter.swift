//
//  DateFormatter.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/6/25.
//

import Foundation

// MARK: - Date Extension for Formatting

extension Date {
    /// Converts the Date instance into a formatted string with the format "MMMM d, yyyy h:mm a".
    /// Example: "March 6, 2025 3:30 PM"
    /// - Returns: A formatted date-time string.
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a" // Customize format as needed
        return formatter.string(from: self)
    }
}

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

/// Formats an optional Date object into a time string using the specified style.
/// Defaults to `.short` style (e.g., "3:30 PM").
/// - Parameters:
///   - date: The optional date to be formatted.
///   - style: The desired `DateFormatter.Style` for the time output (default: `.short`).
/// - Returns: A formatted time string, or an empty string if `date` is nil.
func formatDate(_ date: Date?, style: DateFormatter.Style = .short) -> String {
    guard let date = date else {
        return ""
    }
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = style
    return formatter.string(from: date)
}
