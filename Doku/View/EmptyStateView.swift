//
//  EmptyStateView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isOnboarding") var isOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    ForEach((0...2).reversed(), id: \.self){ card in
                        VStack {
                            Spacer()
                            
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
                                .stroke(Color.isabeline, lineWidth: 5)
                        )
                        .rotationEffect(.degrees(Double(card * 6)))
                        .offset(x: Double(card * -12), y: Double(card * -8))
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
                
                VStack(spacing: 0) {
                    Text("... or restart the guide.")
                        .font(.raleway(size: 16, weight: 400))
                    
                    Button {
                        withAnimation(.spring()) {
                            isOnboarding = true
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Restart Guide")
                                .font(.raleway(size: 20, weight: 700))
                                .foregroundStyle(.isabeline)
                            
                            Image(systemName: "arror.right.circle")
                                .imageScale(.large)
                                .foregroundStyle(.isabeline)
                        }
                        .frame(width: 220, height: 50)
                        .background(.coral)
                        .cornerRadius(12.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(.coral, lineWidth: 0)
                        )
                        .padding()
                    }
                }
            }
        }
        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
        .ignoresSafeArea()
        .overlay {
            if isOnboarding {
                OnboardingView()
                    .overlay {
                        VStack {
                            HStack() {
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        isOnboarding = false
                                    }
                                } label: {
                                    Text("Cancel")
                                        .foregroundStyle(.alabaster)
                                        .imageScale(.large)
                                        .safeAreaPadding()
                                }
                            }
                            Spacer()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
}

#Preview {
    EmptyStateView()
}
