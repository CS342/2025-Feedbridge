//
//  AddDataView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 2/8/25.
//

import Foundation
import SpeziAccount
import SpeziContact
import SwiftUI

struct AddDataAView: View {
    // MARK: - Properties
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    private let dataEntries: [DataEntry] = [
        DataEntry(
            label: "Feed Entry",
            image: Image(systemName: "flame.fill"),
            action: { /* logic to handle feed entry */ }
        ),
        DataEntry(
            label: "Wet Diaper Entry",
            image: Image(systemName: "drop.fill"),
            action: { /* logic to handle wet diaper entry */ }
        ),
        DataEntry(
            label: "Stool Entry",
            image: Image(systemName: "plus.circle.fill"),
            action: { /* logic to handle stool entry */ }
        ),
        DataEntry(
            label: "Dehydration Check",
            image: Image(systemName: "exclamationmark.triangle.fill"),
            action: { /* logic to handle dehydration check */ }
        ),
        DataEntry(
            label: "Weight Entry",
            image: Image(systemName: "scalemass.fill"),
            action: { /* logic to handle weight entry */ }
        )
    ]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ContactsList(contacts: contacts)
                .navigationTitle("Add Data")
                .toolbar {
                    if account != nil {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
    
    private var contacts: [Contact] {
        dataEntries.map { entry in
            Contact(
                name: PersonNameComponents(givenName: entry.label),
                image: entry.image,
                title: "Entry",
                description: nil,
                organization: nil,
                address: nil,
                contactOptions: [
                    ContactOption(
                        image: entry.image,
                        title: entry.label,
                        action: entry.action
                    )
                ]
            )
        }
    }

    // MARK: - Initializer
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}

// MARK: - Supporting Types
extension AddDataAView {
    struct DataEntry {
        let label: String
        let image: Image
        let action: () -> Void
    }
}

#if DEBUG
#Preview {
    AddDataAView(presentingAccount: .constant(false))
}
#endif
