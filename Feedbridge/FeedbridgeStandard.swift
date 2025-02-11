//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

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

    // periphery:ignore:parameters isolation
    func add(
        response: ModelsR4.QuestionnaireResponse, isolation _: isolated (any Actor)? = #isolation
    ) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString

        if FeatureFlags.disableFirebase {
            let jsonRepresentation =
                (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            await logger.debug("Received questionnaire response: \(jsonRepresentation)")
            return
        }

        do {
            try await configuration.userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            await logger.error("Could not store questionnaire response: \(error)")
        }
    }

    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
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
    @MainActor
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
                await logger.error("Could not create path for writing consent form to user document directory.")
                return
            }

            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)

            return
        }

        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                await logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            await logger.error("Could not store consent form: \(error)")
        }
    }

    @MainActor
    func addBabies(babies: [Baby]) async throws {
        guard let id = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
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
                await logger.error("Could not store baby: \(error)")
                return
            }
        }
    }

    @MainActor
    func getBabies() async throws -> [Baby] {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return []
        }

        let fireStore = Firestore.firestore()
        let babiesCollection = fireStore.collection("users").document(userId).collection("babies")

        do {
            let snapshot = try await babiesCollection.getDocuments()
            return try snapshot.documents.map { try $0.data(as: Baby.self) }
        } catch {
            await logger.error("Could not fetch babies: \(error)")
            throw error
        }
    }

    @MainActor
    func getBaby(id: String) async throws -> Baby? {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return nil
        }

        let fireStore = Firestore.firestore()
        let babyRef = fireStore
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
            await logger.error("Could not fetch baby: \(error)")
            throw error
        }
    }

    @MainActor
    func addWeightEntry(_ entry: WeightEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }

        let fireStore = Firestore.firestore()
        let entriesCollection = fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)
            .collection("weightEntries")

        try await entriesCollection.document().setData(from: entry)
    }

    @MainActor
    func addFeedEntry(_ entry: FeedEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }

        let fireStore = Firestore.firestore()
        let entriesCollection = fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)
            .collection("feedEntries")

        try await entriesCollection.document().setData(from: entry)
    }

    @MainActor
    func addStoolEntry(_ entry: StoolEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }

        let fireStore = Firestore.firestore()
        let entriesCollection = fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)
            .collection("stoolEntries")

        try await entriesCollection.document().setData(from: entry)
    }

    @MainActor
    func addWetDiaperEntry(_ entry: WetDiaperEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }

        let fireStore = Firestore.firestore()
        let entriesCollection = fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)
            .collection("wetDiaperEntries")

        try await entriesCollection.document().setData(from: entry)
    }

    @MainActor
    func addDehydrationCheck(_ check: DehydrationCheck, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }

        let fireStore = Firestore.firestore()
        let checksCollection = fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)
            .collection("dehydrationChecks")

        try await checksCollection.document().setData(from: check)
    }
}
