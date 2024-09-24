//
//  EntryDetailView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: DokuEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            //MARK: ARTICLE
            if entry.contentType == .article {
                VStack {
                    HStack(alignment: .center) {
                        if let url = entry.url {
                            ZStack {
                                AsyncImage(url: URL(string: FavIcon(url)[.m]))
                                    .clipShape(RoundedRectangle(cornerRadius: 18.0))
                            }
                        }
                        
                        Text(cleanURL(url: entry.url!))
                            .font(.literata(size: 20, weight: 600))
                            .foregroundStyle(.mintCream)
                            .lineLimit(2)
                    }
                    .padding(.top)
                    
                    if let url = URL(string: entry.url!) {
                        LinkPreviewImageView(url: url)
                            .frame(width: 150, height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    } else {
                        Text("Invalid URL")
                    }
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Created at: " + dateFormatter(date: entry.createdAt))
                            .font(.raleway(size: 18, weight: 500))
                            .foregroundStyle(.mintGreen)
                            .textScale(.secondary)
                        
                        Text(entry.title)
                            .lineLimit(2)
                            .font(.raleway(size: 24, weight: 800))
                            .foregroundStyle(.mintCream)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            // MARK: PASSAGE
            else if entry.contentType == .passage {
                VStack {
                    Spacer()
                    
                    Text(entry.content!)
                        .font(.literata(size: 20, weight: 500))
                        .foregroundStyle(.mintCream)
                        .lineLimit(7)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Created at: " + dateFormatter(date: entry.createdAt))
                                .font(.raleway(size: 18, weight: 500))
                                .foregroundStyle(.mintGreen)
                                .textScale(.secondary)
                            
                            Text(entry.title)
                                .lineLimit(2)
                                .font(.raleway(size: 24, weight: 800))
                                .foregroundStyle(.mintCream)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
            // MARK: TWEET
            else if entry.contentType == .tweet {
                VStack {
                    Spacer()
                    
                    // TODO: Find a way to get the actual tweet!!
                    Text("This is not an actual tweet. This is just a placeholder.")
                        .font(.literata(size: 20, weight: 500))
                        .foregroundStyle(.mintCream)
                        .lineLimit(7)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Spacer()
                        
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Created at: " + dateFormatter(date: entry.createdAt))
                                .font(.raleway(size: 18, weight: 500))
                                .foregroundStyle(.mintGreen)
                                .textScale(.secondary)
                            
                            Text(entry.title)
                                .lineLimit(2)
                                .font(.raleway(size: 24, weight: 800))
                                .foregroundStyle(.mintCream)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
            Button {
                // open in browser
            } label: {
                HStack(alignment: .center) {
                    Text(entry.contentType == .passage ? "Copy to clipboard" : "Open the source")
                    Image(systemName: entry.contentType == .passage ? "doc.on.doc" : "arrow.up.right")
                }
                .font(.raleway(size: 20, weight: 600))
                .foregroundStyle(.mintCream)
                .frame(width: 250, height: 50)
            }
            .background(.davysGray)
            .cornerRadius(12.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(.mintGreen.opacity(0.3), lineWidth: 4)
            )
            .padding()
        }
        .padding()
        .frame(width: 300, height: 450)
        .background(.davysGray)
        .cornerRadius(12.0)
        .overlay(
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(.mintGreen.opacity(0.3), lineWidth: 4)
        )
        .padding()
    }
        
}

private func dateFormatter(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    
    let formattedDate = formatter.string(from: date)
    
    return formattedDate
}

private func cleanURL(url: String) -> String {
    var cleanedURL = String(url.split(separator: "/").dropFirst().first!)
    cleanedURL.replace("www.", with: "")
    
    return cleanedURL
}

#Preview {
    EntryDetailView(entry: DokuEntry(userID: "user1", url: "https://www.x.com/user/status/18321739", title: "Lorem ipsum", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", contentType: .article, tags: ["personal", "website"], createdAt: Date(), lastAccessedAt: Date()))
}
