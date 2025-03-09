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

func dateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func formatDate(_ date: Date?, style: DateFormatter.Style = .short) -> String {
    guard let date = date else { return "" }
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = style
    return formatter.string(from: date)
}
