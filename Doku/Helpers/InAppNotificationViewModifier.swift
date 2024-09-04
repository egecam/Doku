//
//  InAppNotificationViewModifier.swift
//  Doku
//
//  Created by Ege Çam on 30.08.2024.
//

import SwiftUI

struct InAppNotificationViewModifier: ViewModifier {
    @ObservedObject var notificationManager = NotificationManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if notificationManager.isShowingNotification, let notification = notificationManager.currentNotification {
                    VStack {
                        Text(notification.content)
                            .font(.literata(size: 16, weight: 600))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(colorForType(notification.type))
                            .background(backgroundForType(notification.type))
                            .foregroundColor(.alabaster)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 3)
                            .padding(.horizontal)
                            .overlay {
                                if notification.showFireworks {
                                    FireworksView()
                                }
                            }
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .animation(.spring(), value: notificationManager.isShowingNotification)
                }
            }
    }
    
    func backgroundForType(_ type: NotificationType) -> Color {
        switch type {
        case .favourite, .unfavourite:
            return .celadon
        case .delete:
            return .lightCoral
        case .welcomeBack:
            return .apricot
        }
    }
    
    func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .favourite, .unfavourite:
            return .asparagus
        case .delete:
              return .auburn
        case .welcomeBack:
            return .coral
        }
    }
}

struct FireworksView: View {
    @State private var fireworks: [(id: Int, x: CGFloat, y: CGFloat, color: Color)] = []
    
    var body: some View {
        ZStack {
            ForEach(fireworks, id: \.id) { firework in
                Circle()
                    .fill(firework.color)
                    .frame(width: 10, height: 10)
                    .position(x: firework.x, y: firework.y)
                    .opacity(0)
                    .animation(.easeOut(duration: 1).repeatCount(1, autoreverses: false), value: firework.y)
            }
        }
        .onAppear {
            createFireworks()
        }
    }
    
    func createFireworks() {
        for i in 0..<20 {
            let randomX = CGFloat.random(in: 0...300)
            let randomY = CGFloat.random(in: 0...100)
            let color = Color(red: .random(in: 0...1),
                              green: .random(in: 0...1),
                              blue: .random(in: 0...1))
            fireworks.append((id: i, x: randomX, y: randomY, color: color))
        }
    }
}
