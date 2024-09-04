//
//  HomeView.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State var tabSelection: Int = 0
    
    var body: some View {
        TabView {
            NavigationStack {
                    if viewModel.entries.isEmpty {
                        EmptyStateView()
                    } else {
                        EntriesGridView(viewModel: viewModel, selectedTag: $viewModel.selectedTags, entries: viewModel.entries, tags: viewModel.tags)
                            .refreshable {
                                viewModel.fetchEntries()
                                viewModel.fetchTags()
                            }
                    }
            }
            .tabItem { Label("Saved", systemImage: "bookmark") }
            
            withAnimation {
                Text("Subscriptions")
                    .tabItem { Label("Subscriptions", systemImage: "network") }
            }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    HomeView()
}
