//
//  HelperFunctions.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/7/25.
//
import Foundation

/// Defines the x-axis range for the last 7 days
func last7DaysRange() -> ClosedRange<Date> {
    let today = Date()
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today
    return sevenDaysAgo...today
}

/// Formats a date into a string (e.g., "2025-03-06 AM" or "2025-03-06 PM") for grouping
func dateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd a" // 'a' adds AM/PM
    return formatter.string(from: date)
}
