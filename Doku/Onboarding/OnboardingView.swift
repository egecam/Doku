//
//  OnboardingView.swift
//  Doku
//
//  Created by Ege Çam on 7.09.2024.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    @State private var isUserSwiping = false
    
    var cards: [OnboardingCardModel] = onboardingCardData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, item in
                    OnboardingCardView(card: item, isLastCard: index == cards.count - 1, moveNext: moveNext)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(currentIndex == index ? 1 : 0)
                        .scaleEffect(currentIndex == index ? 1 : 0.8)
                        .offset(x: CGFloat(index - currentIndex) * geometry.size.width + offset, y: 0)
                        .animation(.spring(), value: currentIndex)
                        .animation(.spring(), value: offset)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isUserSwiping = true
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.2
                        if value.translation.width < -threshold && currentIndex < cards.count - 1 {
                            currentIndex += 1
                        } else if value.translation.width > threshold && currentIndex > 0 {
                            currentIndex -= 1
                        }
                        withAnimation(.spring()) {
                            offset = 0
                            isUserSwiping = false
                        }
                    }
            )
        }
        .background(.jet)
        .overlay(
            HStack(spacing: 8) {
                ForEach(0..<cards.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.white : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
                .padding(.bottom, 20),
            alignment: .bottom
        )
    }
    
    private func moveNext() {
        withAnimation(.spring()) {
            if currentIndex < cards.count - 1 {
                currentIndex += 1
            }
        }
    }
}


#Preview {
    OnboardingView()
}
