//
//  HelperFunctions.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/7/25.
//
import Foundation

/// Returns a date range representing the last 7 days with half a day of visual padding.
/// - Returns: A `ClosedRange<Date>` from 7 days ago to today with slight extra spacing.
func last7DaysRange() -> ClosedRange<Date> {
    let today = Date()
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today

    let calendar = Calendar.current
    let paddedStart = calendar.date(byAdding: .hour, value: -3, to: sevenDaysAgo) ?? sevenDaysAgo
    let paddedEnd = calendar.date(byAdding: .hour, value: 12, to: today) ?? today

    return paddedStart...paddedEnd
}
