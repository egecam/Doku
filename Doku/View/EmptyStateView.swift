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
                ZStack {
                    ForEach(0..<3){ card in
                        VStack {
                            Spacer()
                            
                            // TODO: Find a way to get the actual tweet!!
                            Text("Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules.")
                                .font(.literata(size: 18, weight: 500))
                                .foregroundStyle(.mintCream)
                                .lineLimit(4)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("03.11.2024")
                                        .font(.raleway(size: 14, weight: 500))
                                        .foregroundStyle(.mintGreen)
                                        .textScale(.secondary)
                                    
                                    Text("Think Different")
                                        .lineLimit(2)
                                        .font(.raleway(size: 18, weight: 800))
                                        .foregroundStyle(.mintCream)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding()
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(width: 175, height: 275)
                        .background(.outerSpace)
                        .clipShape(RoundedRectangle(cornerRadius: 18.0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.mintCream, lineWidth: 3)
                        )
                        .rotationEffect(.degrees(Double(card * 10)))
                    }
                }
                .padding(.bottom)
                
                VStack(spacing: 10) {
                    Text("Your Doku is empty.")
                        .font(.vollkorn(size: 24, weight: 600))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Saved things will be shown here.")
                        .font(.raleway(size: 16, weight: 500))
                    
                    HStack(spacing: 16) {
                        Image(systemName: "info.bubble.fill")
                            .imageScale(.large)
                        
                        Text("Share a link, passage or tweet with Doku on any app.")
                            .font(.literata(size: 18, weight: 500))
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .padding(.top, 10)
                    .symbolEffect(.pulse)
                }
                .padding()
                .frame(alignment: .center)
            }
        }
        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyStateView()
}
