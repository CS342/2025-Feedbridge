//
//  HelperFunctions.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/7/25.
//
import Foundation

/// Returns a date range representing the last 7 days, including today.
/// - Returns: A `ClosedRange<Date>` from 6 days ago to today.
func last7DaysRange() -> ClosedRange<Date> {
    let today = Date()
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today
    return sevenDaysAgo...today
}
