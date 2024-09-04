//
//  ShareViewPreview.swift
//  Doku
//
//  Created by Ege Çam on 27.08.2024.
//

import SwiftUI

// This goes in your main app target, not the extension
struct ShareViewPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var title: String = ""
    @State private var tags: String = ""
    let url: URL?
    let text: String?
    let contentType: ContentType
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Text("Save to Doku")
                    .font(.vollkorn(size: 26, weight: 500))
                    .padding(.top)
                
                VStack(alignment: .leading) {
                    
                    switch contentType {
                    case .article, .tweet:
                        if let url = url {
                            Text("URL: \(url.absoluteString)")
                        }
                    case .passage:
                        if let text = text {
                            Text("Passage: \(text.prefix(100))...")
                        }
                    case .unknown:
                        Text("Unknown content type")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.0)
                            .stroke(colorScheme == .light ? .gray.opacity(0.2) : .davysGray, lineWidth: 3)
                            .fill(.outerSpace.opacity(0.4))
                            .frame(height: 50)
                        
                        TextField(text: $title) {
                            Text("Title")
                        }
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding(13)
                    }
                    
                    ZStack {
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(colorScheme == .light ? .gray.opacity(0.2) : .davysGray, lineWidth: 3)
                                .fill(.outerSpace.opacity(0.4))
                                .frame(height: 50)
                        
                        TextField(text: $tags) {
                            Text("Tags (comma-separated)")
                        }
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding(13)
                    }
                    
                }
                .padding()
                
                
                Button {
                    print("Saved")
                } label: {
                    Text("Save")
                        .font(.raleway(size: 22, weight: 600))
                        .frame(width: 250, height: 50)
                }
                .background(.green.opacity(0.3))
                .cornerRadius(12.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(.green.opacity(0.6), lineWidth: 3)
                )
                .padding()
                
            }
            .font(.literata(size: 18, weight: 400))
            .foregroundStyle(colorScheme == .light ? Color.jet : Color.alabaster)
        }
    }
}

struct ShareViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShareViewPreview(
                url: URL(string: "https://example.com/article"),
                text: nil,
                contentType: .article
            )
            .previewDisplayName("Article")
            
            ShareViewPreview(
                url: URL(string: "https://twitter.com/username/status/123456789"),
                text: nil,
                contentType: .tweet
            )
            .previewDisplayName("Tweet")
            
            ShareViewPreview(
                url: nil,
                text: "This is a sample passage of text for the preview.",
                contentType: .passage
            )
            .previewDisplayName("Passage")
        }
    }
}
