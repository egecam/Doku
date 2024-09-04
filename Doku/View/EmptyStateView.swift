//
//  EmptyStateView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 10) {
                Text("Your Doku is empty.")
                    .font(.vollkorn(size: 24, weight: 600))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Saved things will be shown here.")
                    .font(.raleway(size: 16, weight: 500))
                
                HStack(spacing: 16) {
                    Image(systemName: "info.bubble.fill")
                        .imageScale(.large)
                    
                    Text("Share a link, text or tweet with Doku.")
                        .font(.literata(size: 18, weight: 500))
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 20)
                .symbolEffect(.pulse)
            }
            .padding()
            .frame(alignment: .center)
        }
        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyStateView()
}
