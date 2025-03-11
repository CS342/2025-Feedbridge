//
//  WetDiapersView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI

/// A view that displays a chart of wet diaper entries and a list of detailed entries.
struct WetDiapersView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [WetDiaperEntry]
    let babyId: String

    var body: some View {
        NavigationStack {
            // Display the full Wet Diaper chart with entries
            WetDiaperChart(entries: entries, isMini: false)
                .frame(height: 300)  // Set the height of the chart
                .padding()  // Add padding around the chart

            // Display the list of wet diaper entries
            wetDiaperEntriesList
        }
        .navigationTitle("Voids")  // Set the title of the navigation bar
    }

    /// A view that displays a list of Wet Diaper Entries
    private var wetDiaperEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                // Display the volume and color of the wet diaper entry
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)  // Make the text bold and larger for the volume and color

                // Display the formatted date and time of the entry
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)  // Smaller text for the date and time
                    .foregroundColor(.gray)  // Make the text gray
                    .swipeActions {
                        Button(role: .destructive) { Task {
                            print("Delete wet diaper entry with id: \(entry.id ?? "")")
                        print("Baby: \(babyId)")
                            try await standard.deleteWetDiaperEntry(babyId: babyId, entryId: entry.id ?? "")
                            self.entries.removeAll { $0.id == entry.id }
                        } } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
