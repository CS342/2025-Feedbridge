//
//  DateFormatter.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/6/25.
//

import Foundation

// Extension for Date to provide a custom formatted string
extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a" // Adjust the format as needed
        return formatter.string(from: self)
    }
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

