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
