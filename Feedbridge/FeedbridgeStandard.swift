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
    AccountNotifyConstraint
{
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
        response: ModelsR4.QuestionnaireResponse, isolation: isolated (any Actor)? = #isolation
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
                .collection("QuestionnaireResponse")  // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id)  // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            await logger.error("Could not store questionnaire response: \(error)")
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
                await logger.error(
                    "Could not create path for writing consent form to user document directory.")
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
    func getBaby(id: String) async throws -> Baby? {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return nil
        }
        
        let fireStore = Firestore.firestore()
        let babyDocument = fireStore.collection("users").document(userId).collection("babies").document(id)
        
        do {
            let baby = try await babyDocument.getDocument(as: Baby.self)
            return baby
        } catch {
            await logger.error("Could not fetch baby: \(error)")
            throw error
        }
    }
    
    @MainActor
    func addFeedEntry(_ entry: FeedEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }
        
        let fireStore = Firestore.firestore()
        let babyDocument = fireStore.collection("users").document(userId)
            .collection("babies").document(babyId)
            .collection("feedEntries").document()
        
        try await babyDocument.setData(from: entry)
    }
    
    @MainActor
    func addWeightEntry(_ entry: WeightEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }
        
        let fireStore = Firestore.firestore()
        let entryDocument = fireStore.collection("users").document(userId)
            .collection("babies").document(babyId)
            .collection("weightEntries").document()
        
        try await entryDocument.setData(from: entry)
    }
    
    @MainActor
    func addStoolEntry(_ entry: StoolEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }
        
        let fireStore = Firestore.firestore()
        let entryDocument = fireStore.collection("users").document(userId)
            .collection("babies").document(babyId)
            .collection("stoolEntries").document()
        
        try await entryDocument.setData(from: entry)
    }
    
    @MainActor
    func addWetDiaperEntry(_ entry: WetDiaperEntry, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }
        
        let fireStore = Firestore.firestore()
        let entryDocument = fireStore.collection("users").document(userId)
            .collection("babies").document(babyId)
            .collection("wetDiaperEntries").document()
        
        try await entryDocument.setData(from: entry)
    }
    
    @MainActor
    func addDehydrationCheck(_ check: DehydrationCheck, toBabyWithId babyId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            await logger.error("Could not get current user id")
            return
        }
        
        let fireStore = Firestore.firestore()
        let checkDocument = fireStore.collection("users").document(userId)
            .collection("babies").document(babyId)
            .collection("dehydrationChecks").document()
        
        try await checkDocument.setData(from: check)
    }
}
