//
//  OnboardingCardView.swift
//  Doku
//
//  Created by Ege Çam on 7.09.2024.
//

import SwiftUI

struct OnboardingCardView: View {
    @State private var isAnimating: Bool = false
    var card: OnboardingCardModel
    var isLastCard: Bool
    var moveNext: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text(card.title)
                        .font(.vollkorn(size: 32, weight: 600))
                        .foregroundStyle(.jet)
                    
                    Text(card.headline)
                        .font(.literata(size: 22, weight: 500))
                        .foregroundStyle(.davysGray)
                        .multilineTextAlignment(.leading)
                    
                    if card.media != nil {
                        Image(card.media!)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .frame(width: 300, height: 300)
                .background(Color.alabaster)
                .cornerRadius(30.0)
               
            Spacer()
            
            OnboardingButtonView(title: card.buttonTitle, isLastCard: isLastCard, action: moveNext)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        
    }
}

struct OnboardingButtonView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    var title: String
    var isLastCard: Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            if isLastCard {
                isOnboarding = false
            } else {
                action()
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.raleway(size: 24, weight: 700))
                    .foregroundStyle(.isabeline)
                
                Image(systemName: "arror.right.circle")
                    .imageScale(.large)
                    .foregroundStyle(.isabeline)
            }
            .frame(width: 300, height: 50)
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
