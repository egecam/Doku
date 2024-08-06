//
//  HomeView.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                Group {
                    if viewModel.entries.isEmpty {
                        EmptyStateView()
                    } else {
                        EntriesGridView(entries: viewModel.entries)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Edit") {
                                        //
                                    }
                                }
                            }
                            .refreshable {
                                viewModel.fetchEntries()
                            }
                    }
                }
            }
            .tabItem { Label("Saved", systemImage: "bookmark") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .tint(.primary)
        .onAppear {
            
            viewModel.fetchEntries()
            
        }
    }
}

#Preview {
    HomeView()
}
