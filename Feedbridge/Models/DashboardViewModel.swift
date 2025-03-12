//
//  DashboardViewModel.swift
//  Feedbridge
//
//  Created by Calvin Xu on 3/10/25.
//UserDefaults.standard.selectedBabyId
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Observation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    // MARK: - Public observable properties

    /// The Baby currently displayed by the dashboard
    var baby: Baby?

    /// Whether the view model is currently loading data
    var isLoading = false

    /// Holds an error message if an error occurs, otherwise `nil`
    var errorMessage: String?

    // MARK: - Private Firestore listener references

    private var babyDocListener: ListenerRegistration?
    private var feedEntriesListener: ListenerRegistration?
    private var weightEntriesListener: ListenerRegistration?
    private var stoolEntriesListener: ListenerRegistration?
    private var wetDiaperEntriesListener: ListenerRegistration?
    private var dehydrationChecksListener: ListenerRegistration?

    // MARK: - Lifecycle

    //    deinit {
    //        // Clean up all listeners if for some reason the VM goes out of scope
    //        stopListening()
    //    }

    // MARK: - Public methods

    func startListening(babyId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User is not authenticated."
            return
        }

        isLoading = true
        errorMessage = nil

        let fireStore = Firestore.firestore()
        let babyRef =
            fireStore
            .collection("users")
            .document(userId)
            .collection("babies")
            .document(babyId)

        // 1) Listen to the baby document
        babyDocListener = babyRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self else {
                return
            }
            if let error {
                self.errorMessage = "Failed to load baby document: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            guard let doc = documentSnapshot, doc.exists else {
                self.baby = nil
                return
            }

            do {
                var freshBaby = try doc.data(as: Baby.self)
                // If we already had subcollection data loaded, preserve it
                // so that doc updates won't wipe out subcollection arrays
                if let existing = self.baby {
                    freshBaby.feedEntries = existing.feedEntries
                    freshBaby.weightEntries = existing.weightEntries
                    freshBaby.stoolEntries = existing.stoolEntries
                    freshBaby.wetDiaperEntries = existing.wetDiaperEntries
                    freshBaby.dehydrationChecks = existing.dehydrationChecks
                }
                self.baby = freshBaby
            } catch {
                self.errorMessage = "Failed to decode baby document: \(error.localizedDescription)"
            }

            self.isLoading = false
        }

        // 2) Listen to each subcollection
        listenToFeedEntries(babyRef: babyRef)
        listenToWeightEntries(babyRef: babyRef)
        listenToStoolEntries(babyRef: babyRef)
        listenToWetDiaperEntries(babyRef: babyRef)
        listenToDehydrationChecks(babyRef: babyRef)
    }

    /// Stops listening to all snapshot listeners to avoid memory leaks or spurious updates.
    func stopListening() {
        babyDocListener?.remove()
        babyDocListener = nil

        feedEntriesListener?.remove()
        feedEntriesListener = nil

        weightEntriesListener?.remove()
        weightEntriesListener = nil

        stoolEntriesListener?.remove()
        stoolEntriesListener = nil

        wetDiaperEntriesListener?.remove()
        wetDiaperEntriesListener = nil

        dehydrationChecksListener?.remove()
        dehydrationChecksListener = nil
    }

    // MARK: - Private subcollection listeners

    private func listenToFeedEntries(babyRef: DocumentReference) {
        feedEntriesListener =
            babyRef
            .collection("feedEntries")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    self.errorMessage = "Failed to load feed entries: \(error.localizedDescription)"
                    return
                }
                guard let docs = querySnapshot?.documents else {
                    return
                }

                do {
                    let feeds = try docs.map { try $0.data(as: FeedEntry.self) }
                    var updated = self.baby ?? Baby(name: "", dateOfBirth: Date())
                    updated.feedEntries = FeedEntries(feedEntries: feeds)
                    self.baby = updated
                } catch {
                    self.errorMessage = "Failed to decode feed entries: \(error.localizedDescription)"
                }
            }
    }

    private func listenToWeightEntries(babyRef: DocumentReference) {
        weightEntriesListener =
            babyRef
            .collection("weightEntries")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    self.errorMessage = "Failed to load weight entries: \(error.localizedDescription)"
                    return
                }
                guard let docs = querySnapshot?.documents else {
                    return
                }

                do {
                    let weights = try docs.map { try $0.data(as: WeightEntry.self) }
                    var updated = self.baby ?? Baby(name: "", dateOfBirth: Date())
                    updated.weightEntries = WeightEntries(weightEntries: weights)
                    self.baby = updated
                } catch {
                    self.errorMessage = "Failed to decode weight entries: \(error.localizedDescription)"
                }
            }
    }

    private func listenToStoolEntries(babyRef: DocumentReference) {
        stoolEntriesListener =
            babyRef
            .collection("stoolEntries")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    self.errorMessage = "Failed to load stool entries: \(error.localizedDescription)"
                    return
                }
                guard let docs = querySnapshot?.documents else {
                    return
                }

                do {
                    let stools = try docs.map { try $0.data(as: StoolEntry.self) }
                    var updated = self.baby ?? Baby(name: "", dateOfBirth: Date())
                    updated.stoolEntries = StoolEntries(stoolEntries: stools)
                    self.baby = updated
                } catch {
                    self.errorMessage = "Failed to decode stool entries: \(error.localizedDescription)"
                }
            }
    }

    private func listenToWetDiaperEntries(babyRef: DocumentReference) {
        wetDiaperEntriesListener =
            babyRef
            .collection("wetDiaperEntries")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    self.errorMessage =
                        "Failed to load wet diaper entries: \(error.localizedDescription)"
                    return
                }
                guard let docs = querySnapshot?.documents else {
                    return
                }

                do {
                    let diapers = try docs.map { try $0.data(as: WetDiaperEntry.self) }
                    var updated = self.baby ?? Baby(name: "", dateOfBirth: Date())
                    updated.wetDiaperEntries = WetDiaperEntries(wetDiaperEntries: diapers)
                    self.baby = updated
                } catch {
                    self.errorMessage =
                        "Failed to decode wet diaper entries: \(error.localizedDescription)"
                }
            }
    }

    private func listenToDehydrationChecks(babyRef: DocumentReference) {
        dehydrationChecksListener =
            babyRef
            .collection("dehydrationChecks")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else {
                    return
                }
                if let error {
                    self.errorMessage =
                        "Failed to load dehydration checks: \(error.localizedDescription)"
                    return
                }
                guard let docs = querySnapshot?.documents else {
                    return
                }

                do {
                    let checks = try docs.map { try $0.data(as: DehydrationCheck.self) }
                    var updated = self.baby ?? Baby(name: "", dateOfBirth: Date())
                    updated.dehydrationChecks = DehydrationChecks(dehydrationChecks: checks)
                    self.baby = updated
                } catch {
                    self.errorMessage =
                        "Failed to decode dehydration checks: \(error.localizedDescription)"
                }
            }
    }
}
