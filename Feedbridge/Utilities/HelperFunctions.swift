//
//  DateIndexer.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/6/25.
//
// Helper function to index entries by date (day) for any type conforming to DateTimeEntry
private func indexEntriesPerDay<T: DateTimeEntry>(_ entries: [T]) -> [(entry: T, index: Int)] {
    let sortedEntries = entries.sorted(by: { $0.dateTime < $1.dateTime })
    var dailyIndex: [String: Int] = [:]

    return sortedEntries.map { entry in
        let dayKey = dateString(entry.dateTime)
        let index = (dailyIndex[dayKey] ?? 0) + 1
        dailyIndex[dayKey] = index
        return (entry, index)
    }
}

private func dateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"  // Format to compare the day
    return dateFormatter.string(from: date)
}

