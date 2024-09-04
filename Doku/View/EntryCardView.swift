//
//  EntryCardView.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import SwiftUI
import UIKit
import LinkPresentation

struct EntryCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let entry: DokuEntry
    
    @StateObject private var linkViewModel = LinkViewModel()
    
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
                                .font(.literata(size: 16, weight: 600))
                                .foregroundStyle(.mintCream)
                                .lineLimit(1)
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
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dateFormatter(date: entry.createdAt))
                                .font(.raleway(size: 14, weight: 500))
                                .foregroundStyle(.mintGreen)
                                .textScale(.secondary)
                            
                            Text(entry.title)
                                .lineLimit(2)
                                .font(.raleway(size: 18, weight: 800))
                                .foregroundStyle(.mintCream)
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                        .padding()
                        
                    }
                
            }
            
            // MARK: PASSAGE
            else if entry.contentType == .passage {
                VStack {
                    Spacer()
                    Text(entry.content!)
                        .font(.literata(size: 18, weight: 500))
                        .foregroundStyle(.mintCream)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dateFormatter(date: entry.createdAt))
                                .font(.raleway(size: 14, weight: 500))
                                .foregroundStyle(.mintGreen)
                                .textScale(.secondary)
                                .lineLimit(1)
                            
                            Text(entry.title)
                                .font(.raleway(size: 18, weight: 800))
                                .foregroundStyle(.mintCream)
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
                        .font(.literata(size: 18, weight: 500))
                        .foregroundStyle(.mintCream)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dateFormatter(date: entry.createdAt))
                                .font(.raleway(size: 14, weight: 500))
                                .foregroundStyle(.mintGreen)
                                .textScale(.secondary)
                            
                            Text(entry.title)
                                .lineLimit(2)
                                .font(.raleway(size: 18, weight: 800))
                                .foregroundStyle(.mintCream)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .frame(width: 175, height: 275)
        .background(.outerSpace)
        .clipShape(RoundedRectangle(cornerRadius: 18.0))
    }
}

struct LinkPreviewImageView: View {
    let url: URL
    @StateObject private var viewModel = LinkViewModel()
    
    var body: some View {
        Group {
            if let uiImage = viewModel.previewImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
            } else {
                // Fallback to AsyncImage if LinkPresentation fails
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    case .failure:
                        Color.gray // Placeholder for failed loads
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 150)
            }
        }
        .cornerRadius(12)
        .onAppear {
            viewModel.fetchMetadata(for: url)
        }
    }
}

class LinkViewModel: ObservableObject {
    @Published var previewImage: UIImage?
    
    func fetchMetadata(for url: URL) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let metadata = metadata, let imageProvider = metadata.imageProvider else {
                print("Failed to fetch metadata or image provider")
                return
            }
            
            imageProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.previewImage = image
                    } else if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                    }
                }
            }
        }
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

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)"
    }
}

