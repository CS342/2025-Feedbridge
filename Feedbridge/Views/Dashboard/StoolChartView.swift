//
//  StoolChartView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct StoolChart: View {
    let entries: [StoolEntry]

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)

                VStack {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel("Circle with plus")
                            .font(.title3)
                            .foregroundColor(.cyan)
                            .padding(.leading, 8)

                        Text("Stools")
                            .font(.title3.bold())
                            .foregroundColor(.cyan)
                        
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


