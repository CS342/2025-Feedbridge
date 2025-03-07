//
//  FeedChartView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct FeedChart: View {
    let entries: [FeedEntry]

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)

                VStack {
                    HStack {
                        Image(systemName: "flame.fill")
                            .accessibilityLabel("Flame")
                            .font(.title3)
                            .foregroundColor(.pink)
                            .padding(.leading, 8)

                        Text("Feeds")
                            .font(.title3.bold())
                            .foregroundColor(.pink)
                        
                        Spacer()
                    }
                    .padding()

                    if entries.isEmpty {
                        Text("No data added")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}
