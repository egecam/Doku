//
//  EntriesGridView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EntriesGridView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var entryFavouriteStatus: Bool = false
    @Binding var selectedTag: String?
    
    @State private var isCardExpanded: Bool = false
    @State private var selectedEntry: DokuEntry?
    @State private var searchText = ""
    
    let entries: [DokuEntry]
    let tags: [String]
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var filteredEntries: [DokuEntry] {
        // If both searchText and selectedTag are empty, return all entries
        if searchText.isEmpty && selectedTag == nil {
            return entries
        }
        
        // Filter entries by tag if a tag is selected
        let tagFilteredEntries = selectedTag.map { tag in
            entries.filter { $0.tags.contains(tag) }
        } ?? entries
        
        // If searchText is empty, return only the tag-filtered entries
        if searchText.isEmpty {
            return tagFilteredEntries
        }
        
        // Filter the already tag-filtered entries by searchText
        return tagFilteredEntries.filter { $0.title.contains(searchText) }
    }
    
    var body: some View {
        ZStack {
            mainContent
                .blur(radius: isCardExpanded ? 5 : 0)
                .allowsHitTesting(!isCardExpanded)
            
            if isCardExpanded {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isCardExpanded = false
                        selectedEntry = nil
                        
                    }
                
                if let selectedEntry = selectedEntry {
                    withAnimation(.easeIn(duration: 3)) {
                        EntryDetailView(entry: selectedEntry)
                            .transition(.opacity.combined(with: .scale))
                            .zIndex(1)
                    }
                }
            }
        }
        .animation(.spring(), value: isCardExpanded)
    }
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                tagScrollView
                entriesGridView
                    .searchable(text: $searchText)
            }
            .padding()
        }
        .background(colorScheme == .light ? .alabaster : .jet)
        .scrollIndicators(.hidden)
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Recently Saved")
                .font(.vollkorn(size: 32, weight: 600))
                .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
            
            Spacer()
        }
    }
    
    private var tagScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagButton(tag: tag, isSelected: selectedTag == tag) {
                        withAnimation {
                            selectedTag = selectedTag == tag ? nil : tag
                        }
                    }
                }
            }
        }
    }
    
    private var entriesGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
            ForEach(filteredEntries) { entry in
                EntryCardView(entry: entry)
                    .transition(.opacity.combined(with: .scale))
                    .onTapGesture { location in
                        selectedEntry = entry
                        withAnimation(.spring()) {
                            isCardExpanded = true
                        }
                    }
                    .contextMenu {
                        contextMenuButtons(for: entry)
                    }
            }
        }
    }
    
    private func contextMenuButtons(for entry: DokuEntry) -> some View {
        Group {
            if entry.tags.contains("favourite") {
                Button("Remove from favourites", systemImage: "heart.fill") {
                    updateFavouriteStatus(for: entry, isFavourite: false)
                }
            } else {
                Button("Add to favourites", systemImage: "heart") {
                    updateFavouriteStatus(for: entry, isFavourite: true)
                }
            }
            
            Button(role: .destructive) {
                deleteEntry(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func updateFavouriteStatus(for entry: DokuEntry, isFavourite: Bool) {
        Task {
            await viewModel.updateEntryFavouriteStatus(entryID: entry.id!, entryHasFavouriteTag: !isFavourite)
            NotificationManager.shared.showNotification(
                type: isFavourite ? .favourite : .unfavourite,
                content: "Entry is \(isFavourite ? "added to" : "removed from") your favourites."
            )
            impactMed.impactOccurred()
        }
    }
    
    private func deleteEntry(_ entry: DokuEntry) {
        Task {
            await viewModel.deleteEntry(entryID: entry.id!)
            NotificationManager.shared.showNotification(type: .delete, content: "Entry is removed from your Doku.")
            viewModel.fetchTags()
            impactMed.impactOccurred()
        }
    }
    
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            if tag == "favourite" {
                Label("Favourites", systemImage: "heart.fill")
            } else {
                Text(tag)
            }
        }
        .padding()
        .frame(height: 30)
        .foregroundStyle(isSelected ? .alabaster : (colorScheme == .light ? .jet : .gray))
        .background(Capsule().fill(isSelected ? Color.coral : (colorScheme == .light ? Color.davysGray.opacity(0.3) : Color.davysGray)))
        .animation(.easeInOut, value: isSelected)
    }
}

#Preview {
    HomeView()
}
