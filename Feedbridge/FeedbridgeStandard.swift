//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI

actor FeedbridgeStandard: Standard,
                          EnvironmentAccessible,
                          HealthKitConstraint,
                          ConsentConstraint,
                          AccountNotifyConstraint {
    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration

    init() {}

    func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            return
        }

        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }

    func remove(sample: HKDeletedObject) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new removed healthkit sample with id \(sample.uuid)")
            return
        }

        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }

    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit")  // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString)  // Set the document identifier to the UUID of the document.
    }

    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }

    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: ConsentDocumentExport) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard
                let basePath = FileManager.default.urls(
                    for: .documentDirectory, in: .userDomainMask
                ).first
            else {
                logger.error(
                    "Could not create path for writing consent form to user document directory."
                )
                return
            }

            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)

            return
        }

        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }

    func addBabies(babies: [Baby]) async throws {
        guard let id = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }
        let fireStore = Firestore.firestore()
        let userDocument = fireStore.collection("users").document(id)
        let babiesCollection = userDocument.collection("babies")

        for baby in babies {
            let babyDocument = babiesCollection.document()
            do {
                try await babyDocument.setData(from: baby)
            } catch {
                logger.error("Could not store baby: \(error)")
                return
            }
        }
    }

    func getBabies() async throws -> [Baby] {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return []
        }

        do {
            let fireStore = Firestore.firestore()
            let babiesCollection = fireStore.collection("users").document(userId).collection("babies")

            do {
                let snapshot = try await babiesCollection.getDocuments()
                return try snapshot.documents.map { try $0.data(as: Baby.self) }
            } catch {
                logger.error("Could not fetch babies: \(error)")
                throw error
            }
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func getBaby(id: String) async throws -> Baby? {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return nil
        }

        do {
            let fireStore = Firestore.firestore()
            let babyRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(id)

            do {
                var baby = try await babyRef.getDocument(as: Baby.self)

                // Get weight entries
                let weightSnapshot = try? await babyRef.collection("weightEntries").getDocuments()
                if let documents = weightSnapshot?.documents {
                    let entries = try documents.map { try $0.data(as: WeightEntry.self) }
                    baby.weightEntries = WeightEntries(weightEntries: entries)
                }

                // Get feed entries
                let feedSnapshot = try? await babyRef.collection("feedEntries").getDocuments()
                if let documents = feedSnapshot?.documents {
                    let entries = try documents.map { try $0.data(as: FeedEntry.self) }
                    baby.feedEntries = FeedEntries(feedEntries: entries)
                }

                // Get stool entries
                let stoolSnapshot = try? await babyRef.collection("stoolEntries").getDocuments()
                if let documents = stoolSnapshot?.documents {
                    let entries = try documents.map { try $0.data(as: StoolEntry.self) }
                    baby.stoolEntries = StoolEntries(stoolEntries: entries)
                }

                // Get wet diaper entries
                let wetDiaperSnapshot = try? await babyRef.collection("wetDiaperEntries").getDocuments()
                if let documents = wetDiaperSnapshot?.documents {
                    let entries = try documents.map { try $0.data(as: WetDiaperEntry.self) }
                    baby.wetDiaperEntries = WetDiaperEntries(wetDiaperEntries: entries)
                }

                // Get dehydration checks
                let dehydrationSnapshot = try? await babyRef.collection("dehydrationChecks").getDocuments()
                if let documents = dehydrationSnapshot?.documents {
                    let checks = try documents.map { try $0.data(as: DehydrationCheck.self) }
                    baby.dehydrationChecks = DehydrationChecks(dehydrationChecks: checks)
                }

                return baby
            } catch {
                logger.error("Could not fetch baby: \(error)")
                throw error
            }
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func addWeightEntry(_ entry: WeightEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }

        do {
            let fireStore = Firestore.firestore()
            let entriesCollection =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("weightEntries")

            try await entriesCollection.document().setData(from: entry)
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func addFeedEntry(_ entry: FeedEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }

        do {
            let fireStore = Firestore.firestore()
            let entriesCollection =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("feedEntries")

            try await entriesCollection.document().setData(from: entry)
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func addStoolEntry(_ entry: StoolEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }

        do {
            let fireStore = Firestore.firestore()
            let entriesCollection =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("stoolEntries")

            try await entriesCollection.document().setData(from: entry)
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func addWetDiaperEntry(_ entry: WetDiaperEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }

        do {
            let fireStore = Firestore.firestore()
            let entriesCollection =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("wetDiaperEntries")

            try await entriesCollection.document().setData(from: entry)
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func addDehydrationCheck(_ check: DehydrationCheck, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            return
        }

        do {
            let fireStore = Firestore.firestore()
            let checksCollection =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("dehydrationChecks")

            try await checksCollection.document().setData(from: check)
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteWeightEntry(babyId: String, entryId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let entryRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("weightEntries")
                .document(entryId)

            try await entryRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteFeedEntry(babyId: String, entryId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let entryRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("feedEntries")
                .document(entryId)

            try await entryRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteStoolEntry(babyId: String, entryId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let entryRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("stoolEntries")
                .document(entryId)

            try await entryRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteWetDiaperEntry(babyId: String, entryId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let entryRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("wetDiaperEntries")
                .document(entryId)

            try await entryRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteDehydrationCheck(babyId: String, entryId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let entryRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(babyId)
                .collection("dehydrationChecks")
                .document(entryId)

            try await entryRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }

    func deleteBaby(id: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("Could not get current user id")
            throw NSError(
                domain: "FeedbridgeStandard",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        do {
            let fireStore = Firestore.firestore()
            let babyRef =
                fireStore
                .collection("users")
                .document(userId)
                .collection("babies")
                .document(id)

            // Delete all subcollections first
            // Weight entries
            let weightSnapshot = try await babyRef.collection("weightEntries").getDocuments()
            for document in weightSnapshot.documents {
                try await document.reference.delete()
            }

            // Feed entries
            let feedSnapshot = try await babyRef.collection("feedEntries").getDocuments()
            for document in feedSnapshot.documents {
                try await document.reference.delete()
            }

            // Stool entries
            let stoolSnapshot = try await babyRef.collection("stoolEntries").getDocuments()
            for document in stoolSnapshot.documents {
                try await document.reference.delete()
            }

            // Wet diaper entries
            let wetDiaperSnapshot = try await babyRef.collection("wetDiaperEntries").getDocuments()
            for document in wetDiaperSnapshot.documents {
                try await document.reference.delete()
            }

            // Dehydration checks
            let dehydrationSnapshot = try await babyRef.collection("dehydrationChecks").getDocuments()
            for document in dehydrationSnapshot.documents {
                try await document.reference.delete()
            }

            // Finally delete the baby document itself
            try await babyRef.delete()
        } catch {
            print("Firestore error: \(error)")
            logger.error("Detailed error: \(error)")
            throw error
        }
    }
}
