// //
// //  TestFeedbridgeStandard.swift
// //  Feedbridge
// //
// //  Created by Calvin Xu on 3/10/25.
// //
// // SPDX-FileCopyrightText: 2025 Stanford University
// //
// // SPDX-License-Identifier: MIT
// //

// import FirebaseAuth
// import Foundation
// import Testing

// @testable import Feedbridge

// /// These tests demonstrate integration with Firestore using the `FeedbridgeStandard` actor.
// ///
// /// 1. Firestore must be configured in the test environment (emulator or real Firebase project).
// /// 2. A test user must be signed in for these tests to succeed.
// /// - This file automatically creates and signs in a new test user if none is available.
// /// 3. Make sure `FeatureFlags.disableFirebase` is set to `false` if you want the Firestore writes.
// /// 4. If using an emulator, confirm your `FeedbridgeDelegate` is configured to point to your emulator settings.
// struct TestFeedbridgeStandard {
//   private let standard = FeedbridgeStandard()

//   // MARK: - Test User Setup

//   /// Creates or reuses a test Firebase user for Firestore write operations.
//   /// - Returns: The signed-in Firebase user.
//   private func ensureTestUserIsSignedIn() async throws -> User {
//     if let user = Auth.auth().currentUser {
//       return user
//     }
//     // Generate a random test email to reduce collisions between runs
//     let testEmail = "test\(UUID().uuidString.prefix(5))@example.com"
//     let testPassword = "Test1234!"

//     do {
//       let result = try await Auth.auth().createUser(withEmail: testEmail, password: testPassword)
//       return result.user
//     } catch {
//       // If the user already exists or another issue arises, try sign in
//       let signInResult = try await Auth.auth().signIn(withEmail: testEmail, password: testPassword)
//       return signInResult.user
//     }
//   }

//   // MARK: - Helper: Create Test Baby

//   /// Creates a new `Baby` with a unique name for test usage.
//   private func createTestBaby() -> Baby {
//     Baby(name: "TestBaby-\(UUID().uuidString.prefix(5))", dateOfBirth: Date())
//   }

//   // MARK: - Tests

//   @Test
//   func testAddAndRetrieveBaby() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     // Ensure we have a signed-in user
//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     let testBaby = createTestBaby()

//     // 1) Add a baby
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve all babies
//     let babies = try await standard.getBabies()
//     #expect(
//       Bool(babies.contains { $0.name == testBaby.name }),
//       "Expected to find newly added baby in the list."
//     )

//     // 3) Retrieve baby by ID
//     guard let newlyAddedBaby = babies.first(where: { $0.name == testBaby.name }),
//       let newlyAddedID = newlyAddedBaby.id
//     else {
//       #expect(Bool(false), "Newly added baby has no Firestore ID or wasn't found.")
//       return
//     }

//     let fetchedBaby = try await standard.getBaby(id: newlyAddedID)
//     #expect(
//       Bool(fetchedBaby?.name == testBaby.name),
//       "Fetched baby name should match the one we created."
//     )

//     // 4) Cleanup: delete the test baby
//     try await standard.deleteBaby(id: newlyAddedID)

//     let babiesAfterDelete = try await standard.getBabies()
//     #expect(
//       Bool(!babiesAfterDelete.contains(where: { $0.id == newlyAddedID })),
//       "Expected the baby to be deleted from Firestore."
//     )
//   }

//   @Test
//   func testAddWeightEntryToBaby() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     // 1) Create and add a test baby
//     let testBaby = createTestBaby()
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve the baby to confirm Firestore ID
//     let babies = try await standard.getBabies()
//     guard let newlyAddedBaby = babies.first(where: { $0.name == testBaby.name }),
//       let babyId = newlyAddedBaby.id
//     else {
//       #expect(Bool(false), "Could not retrieve newly added baby from Firestore.")
//       return
//     }

//     // 3) Add a weight entry
//     let weightEntry = WeightEntry(grams: 3500)
//     try await standard.addWeightEntry(weightEntry, toBabyWithId: babyId)

//     // 4) Fetch baby details to confirm the weight entry was stored
//     let fetchedBaby = try await standard.getBaby(id: babyId)
//     #expect(
//       Bool(fetchedBaby?.weightEntries.weightEntries.count == 1),
//       "Baby should have exactly one weight entry."
//     )
//     #expect(
//       Bool(fetchedBaby?.weightEntries.weightEntries.first?.weightInGrams == 3500),
//       "The weight entry value should match the one we saved."
//     )

//     // 5) Cleanup
//     try await standard.deleteBaby(id: babyId)
//     let babiesAfterDelete = try await standard.getBabies()
//     #expect(
//       Bool(!babiesAfterDelete.contains(where: { $0.id == babyId })),
//       "Expected the baby to be deleted from Firestore."
//     )
//   }

//   @Test
//   func testAddAndDeleteFeedEntry() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     // 1) Create and add a baby
//     let testBaby = createTestBaby()
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve the baby
//     let babies = try await standard.getBabies()
//     guard let newBaby = babies.first(where: { $0.name == testBaby.name }),
//       let babyId = newBaby.id
//     else {
//       #expect(Bool(false), "Could not retrieve newly added baby from Firestore.")
//       return
//     }

//     // 3) Add a feed entry
//     let feedEntry = FeedEntry(directBreastfeeding: 15)
//     try await standard.addFeedEntry(feedEntry, toBabyWithId: babyId)

//     // 4) Verify the feed entry was stored
//     let fetchedBaby = try await standard.getBaby(id: babyId)
//     let feedCountBeforeDelete = fetchedBaby?.feedEntries.feedEntries.count ?? 0
//     #expect(Bool(feedCountBeforeDelete == 1), "Baby should have exactly one feed entry.")

//     // 5) Delete the feed entry
//     guard let feedDocId = fetchedBaby?.feedEntries.feedEntries.first?.id else {
//       #expect(Bool(false), "FeedEntry has no Firestore ID; cannot delete.")
//       return
//     }
//     try await standard.deleteFeedEntry(babyId: babyId, entryId: feedDocId)

//     // 6) Validate removal
//     let babyAfterFeedRemoval = try await standard.getBaby(id: babyId)
//     let feedCountAfterDelete = babyAfterFeedRemoval?.feedEntries.feedEntries.count ?? 0
//     #expect(Bool(feedCountAfterDelete == 0), "Expected feed entry to be deleted from Firestore.")

//     // 7) Cleanup
//     try await standard.deleteBaby(id: babyId)
//   }

//   @Test
//   func testAddAndDeleteStoolEntry() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     // 1) Create and add a baby
//     let testBaby = createTestBaby()
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve the baby
//     let babies = try await standard.getBabies()
//     guard let newBaby = babies.first(where: { $0.name == testBaby.name }),
//       let babyId = newBaby.id
//     else {
//       #expect(Bool(false), "Could not retrieve newly added baby from Firestore.")
//       return
//     }

//     // 3) Add a stool entry
//     let stoolEntry = StoolEntry(dateTime: Date(), volume: .medium, color: .brown)
//     try await standard.addStoolEntry(stoolEntry, toBabyWithId: babyId)

//     // 4) Verify the stool entry was stored
//     let fetchedBaby = try await standard.getBaby(id: babyId)
//     let stoolCountBeforeDelete = fetchedBaby?.stoolEntries.stoolEntries.count ?? 0
//     #expect(Bool(stoolCountBeforeDelete == 1), "Baby should have exactly one stool entry.")

//     // 5) Delete the stool entry
//     guard let stoolDocId = fetchedBaby?.stoolEntries.stoolEntries.first?.id else {
//       #expect(Bool(false), "StoolEntry has no Firestore ID; cannot delete.")
//       return
//     }
//     try await standard.deleteStoolEntry(babyId: babyId, entryId: stoolDocId)

//     // 6) Validate removal
//     let babyAfterStoolRemoval = try await standard.getBaby(id: babyId)
//     let stoolCountAfterDelete = babyAfterStoolRemoval?.stoolEntries.stoolEntries.count ?? 0
//     #expect(Bool(stoolCountAfterDelete == 0), "Expected stool entry to be deleted from Firestore.")

//     // 7) Cleanup
//     try await standard.deleteBaby(id: babyId)
//   }

//   @Test
//   func testAddAndDeleteWetDiaperEntry() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     // 1) Create and add a baby
//     let testBaby = createTestBaby()
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve the baby
//     let babies = try await standard.getBabies()
//     guard let newBaby = babies.first(where: { $0.name == testBaby.name }),
//       let babyId = newBaby.id
//     else {
//       #expect(Bool(false), "Could not retrieve newly added baby from Firestore.")
//       return
//     }

//     // 3) Add a wet diaper entry
//     let wetDiaperEntry = WetDiaperEntry(dateTime: Date(), volume: .heavy, color: .pink)
//     try await standard.addWetDiaperEntry(wetDiaperEntry, toBabyWithId: babyId)

//     // 4) Verify the wet diaper entry was stored
//     let fetchedBaby = try await standard.getBaby(id: babyId)
//     let diaperCountBeforeDelete = fetchedBaby?.wetDiaperEntries.wetDiaperEntries.count ?? 0
//     #expect(Bool(diaperCountBeforeDelete == 1), "Baby should have exactly one wet diaper entry.")

//     // 5) Delete the wet diaper entry
//     guard let diaperDocId = fetchedBaby?.wetDiaperEntries.wetDiaperEntries.first?.id else {
//       #expect(Bool(false), "WetDiaperEntry has no Firestore ID; cannot delete.")
//       return
//     }
//     try await standard.deleteWetDiaperEntry(babyId: babyId, entryId: diaperDocId)

//     // 6) Validate removal
//     let babyAfterDiaperRemoval = try await standard.getBaby(id: babyId)
//     let diaperCountAfterDelete =
//       babyAfterDiaperRemoval?.wetDiaperEntries.wetDiaperEntries.count ?? 0
//     #expect(
//       Bool(diaperCountAfterDelete == 0), "Expected wet diaper entry to be deleted from Firestore.")

//     // 7) Cleanup
//     try await standard.deleteBaby(id: babyId)
//   }

//   @Test
//   func testAddAndDeleteDehydrationCheck() async throws {
//     if FeatureFlags.disableFirebase {
//       #expect(Bool(true), "Skipping test because Firebase is disabled.")
//       return
//     }

//     let user = try await ensureTestUserIsSignedIn()
//     #expect(Bool(!user.uid.isEmpty), "We have an authenticated user for Firestore writes.")

//     // 1) Create and add a baby
//     let testBaby = createTestBaby()
//     try await standard.addBabies(babies: [testBaby])

//     // 2) Retrieve the baby
//     let babies = try await standard.getBabies()
//     guard let newBaby = babies.first(where: { $0.name == testBaby.name }),
//       let babyId = newBaby.id
//     else {
//       #expect(Bool(false), "Could not retrieve newly added baby from Firestore.")
//       return
//     }

//     // 3) Add a dehydration check
//     let check = DehydrationCheck(
//       dateTime: Date(), poorSkinElasticity: true, dryMucousMembranes: false)
//     try await standard.addDehydrationCheck(check, toBabyWithId: babyId)

//     // 4) Verify the dehydration check was stored
//     let fetchedBaby = try await standard.getBaby(id: babyId)
//     let checkCountBeforeDelete = fetchedBaby?.dehydrationChecks.dehydrationChecks.count ?? 0
//     #expect(Bool(checkCountBeforeDelete == 1), "Baby should have exactly one dehydration check.")

//     // 5) Delete the dehydration check
//     guard let checkDocId = fetchedBaby?.dehydrationChecks.dehydrationChecks.first?.id else {
//       #expect(
//         Bool(false),
//         "DehydrationCheck has no Firestore ID; cannot delete."
//       )
//       return
//     }
//     try await standard.deleteDehydrationCheck(babyId: babyId, entryId: checkDocId)

//     // 6) Validate removal
//     let babyAfterCheckRemoval = try await standard.getBaby(id: babyId)
//     let checkCountAfterDelete =
//       babyAfterCheckRemoval?.dehydrationChecks.dehydrationChecks.count ?? 0
//     #expect(
//       Bool(checkCountAfterDelete == 0), "Expected dehydration check to be deleted from Firestore.")

//     // 7) Cleanup
//     try await standard.deleteBaby(id: babyId)
//   }
// }
