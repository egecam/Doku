//
//  HomeViewModel.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import os.log

@MainActor
class HomeViewModel: ObservableObject {
    @Published var entries: [DokuEntry] = []
    @Published var tags: [String] = []
    @Published var selectedTags: String?
    
    private var db = Firestore.firestore()
    private let logger = Logger(subsystem: "dev.egecam.Doku", category: "HomeViewModel")
    
    init() {
        logger.log("HomeViewModel initialized")
        fetchEntries()
        fetchTags()
    }
    
    func saveEntry(url: URL?, content: String?, title: String, tags: [String], contentType: ContentType) async {
        logger.log("Attempting to save entry: \(title)")
        
        if let currentUser = Auth.auth().currentUser {
            var entryData: [String: Any] = [
                "userID": currentUser.uid,
                "title": title,
                "contentType": contentType.rawValue,
                "tags": tags,
                "createdAt": Date(),
                "lastAccessedAt": Date()
            ]
            
            if let url = url {
                entryData["url"] = url.absoluteString
            }
            
            if let content = content {
                entryData["content"] = content
            }
            
            do {
                let documentReference = try await db.collection("entries").addDocument(data: entryData)
                logger.log("Entry saved successfully with ID: \(documentReference.documentID)")
                
                // Verify the save by immediately fetching the document
                let document = try await documentReference.getDocument()
                if document.exists {
                    logger.log("Document verified after save: \(document.data() ?? [:])")
                    fetchEntries() // Refresh entries after saving
                } else {
                    logger.error("Document does not exist after save")
                }
            } catch {
                logger.error("Error saving entry: \(error.localizedDescription)")
                testFirestoreConnection()
            }
        } else {
            logger.log("Failed to save entry, cannot find a currentUser.")
        }
    }
    
    func fetchEntries() {
        logger.log("Fetching entries")
        
        if let currentUser = Auth.auth().currentUser {
            db.collection("entries").whereField("userID", isEqualTo: currentUser.uid).order(by: "createdAt", descending: true).addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.logger.error("Error fetching entries: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.logger.log("No documents found")
                    return
                }
                
                self.entries = documents.compactMap { queryDocumentSnapshot in
                    do {
                        let entry = try queryDocumentSnapshot.data(as: DokuEntry.self)
                        self.logger.log("Fetched entry: \(entry.title)")
                        return entry
                    } catch {
                        self.logger.error("Error decoding entry: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                self.logger.log("Fetched \(self.entries.count) entries")
            }
        } else {
            self.logger.log("Failed to fetch entries, cannot find a currentUser.")
        }
    }
    
    func fetchTags() {
        if let currentUser = Auth.auth().currentUser {
            var allTags: [String] = []
            self.tags.removeAll()
            
            db.collection("entries").whereField("userID", isEqualTo: currentUser.uid).addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.logger.log("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                for document in querySnapshot?.documents ?? [] {
                    if let tags = document.get("tags") as? [String] {
                        allTags.append(contentsOf: tags)
                    }
                }
                
                allTags.sort()
                allTags.insert("favourite", at: 0)
                self.tags = allTags.uniqued()
            }
        }
    }
    
    func updateEntryFavouriteStatus(entryID: String, entryHasFavouriteTag: Bool) async {
        self.logger.log("Input entryID: \(entryID)")
        let docRef = db.collection("entries").document(entryID)
        self.logger.log("Fetched entry with the document ID: \(docRef.documentID)")
        
        if !entryHasFavouriteTag {
            // Entry is not favourited, 'favourite' tag will be added
            do {
                try await docRef.updateData([
                    "tags": FieldValue.arrayUnion(["favourite"])
                ])
                self.logger.log("Entry is added to favourites")
            } catch {
                self.logger.log("\(error.localizedDescription)")
            }
            
        } else {
            // Entry is favourited, 'favourite' tag will be removed
            do {
                try await docRef.updateData([
                    "tags": FieldValue.arrayRemove(["favourite"])
                ])
                self.logger.log("Entry is removed from favourites")
            } catch {
                self.logger.log("\(error.localizedDescription)")
            }
        }
        
    }
    
    func deleteEntry(entryID: String) async {
        do {
            try await db.collection("entries").document(entryID).delete()
        } catch {
            self.logger.log("Error getting document: \(error.localizedDescription)")
        }
        
    }
    
    private func testFirestoreConnection() {
        db.collection("entries").addDocument(data: ["test": "test"]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Firestore connection test failed: \(error.localizedDescription)")
            } else {
                self.logger.log("Firestore connection test succeeded")
            }
        }
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted}
    }
}
