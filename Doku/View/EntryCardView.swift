//
//  EntryCardView.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import SwiftUI

struct EntryCardView: View {
    let title: String
    let createdAt: String
    let contentType: ContentType
    let url: String?
    let passage: String?
    let tags: [String]?
    let startDate = Date()
    
    private let degrees: Double = -25.0
    @State private var isExpanded = false
    @State private var blurBackground = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        //MARK: ARTICLE
                        if contentType == .article {
                            Text(url!.split(separator: "/").dropFirst().first!)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .padding()
                            
                            Spacer()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(createdAt)
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .textScale(.secondary)
                                    
                                    Text(title)
                                        .lineLimit(2)
                                        .font(.title3.bold().monospaced())
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                
                                Spacer()
                            }
                            .padding(.bottom)
                            .background(
                                Color.gray
                                    .opacity(0.5)
                                    .frame(width: 300, height: 120)
                            )
                            .offset(y: 30)
                            
                        }
                        
                        // MARK: PASSAGE
                        else if contentType == .passage {
                            VStack {
                                Spacer()
                                
                                Image(systemName: "quote.opening")
                                    .offset(x: -120)
                                    .font(.title3)
                                Text(passage!)
                                    .padding()
                                
                                
                                VStack(alignment: .leading) {
                                    Text(createdAt)
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .textScale(.secondary)
                                    
                                    Text(title)
                                        .font(.title3.bold().monospaced())
                                }
                            }
                            .foregroundStyle(.white)
                        }
                        
                        // MARK: TWEET
                        else if contentType == .tweet {
                            VStack {
                                Spacer()
                                
                                Image(systemName: "bird.fill")
                                    .offset(x: -120)
                                    .font(.title3)
                                
                                // TODO: Find a way to get the actual tweet!!
                                Text("This is not an actual tweet. This is just a placeholder.")
                                    .lineLimit(2)
                                    .padding()
                                
                                
                                VStack(alignment: .leading) {
                                    Text(createdAt)
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .textScale(.secondary)
                                    
                                    Text(title)
                                        .font(.title3.bold().monospaced())
                                }
                            }
                            .foregroundStyle(.white)
                        }
                    }
                }
                .padding()
                .frame(width: 300, height: 200)
                .background(
                    Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 18.0))
                
                
//                if blurBackground {
//                    Color.white.opacity(0)
//                        .background(.ultraThinMaterial)
//                        .edgesIgnoringSafeArea(.all)
//                        .transition(.opacity)
//                        .onTapGesture {
//                            withAnimation {
//                                isExpanded = false
//                                blurBackground = false
//                            }
//                        }
//                }
                
                if let tags = tags {
                    ForEach(0..<tags.count, id: \.self) { tag in
                        ZStack {
                            // TODO: Fetch correct image for each tag
                            Image("stamp\(tag + 1)")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(isExpanded ? 0 : degrees + Double(tag * 10)))
                                .position(x: 330, y: 0)
                                .offset(x: 0, y: isExpanded ? CGFloat(tag * 50 + 10) : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: isExpanded)
                        }
                        // TODO: Add NavigationLink for tags!!
                    }
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
//                            blurBackground = isExpanded
                        }
                    }
                }
                
                
            }
            .animation(.easeInOut, value: isExpanded)
        }
    }
    
}

#Preview {
    EntryCardView(title: "Tweet by egecamdev", createdAt: "03.11.2002", contentType: .article, url: "https://egecam.dev/", passage: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ullamcorper lectus sed est hendrerit aliquet.", tags: ["portfolio", "website", "look-later"])
}

