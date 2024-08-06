//
//  EntriesGridView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI
import LinkPresentation

struct EntriesGridView: View {
    @State private var linkPreview: LPLinkMetadata?
    let entries: [DokuEntry]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 1)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                Section {
                    ForEach(entries) { entry in
                        NavigationLink(destination: {
                            // EntryDetailView(entry: entry)
                        }) {
                            if entry.contentType == .article || entry.contentType == .tweet || entry.contentType == .image {
                                EntryCardView(title: entry.title, createdAt: entry.createdAt.formatted(), contentType: entry.contentType, url: entry.url!, passage: "", tags: entry.tags)
                            } else if entry.contentType == .passage {
                                EntryCardView(title: entry.title, createdAt: entry.createdAt.formatted(), contentType: entry.contentType, url: entry.url!, passage: entry.content, tags: entry.tags)
                            }
                        }
                    }
                } header: {
                    Text("Recently Saved")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .padding()
        }
        .scrollTargetLayout()
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollBounceBehavior(.always)
        
    }
}

