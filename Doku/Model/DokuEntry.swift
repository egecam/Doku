//
//  DokuEntry.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import Foundation
import FirebaseFirestoreSwift

struct DokuEntry: Codable, Identifiable {
    @DocumentID var id: String?
    let userID: String
    let url: String?
    let title: String
    let content: String?
    let contentType: ContentType
    let tags: [String]
    let createdAt: Date
    let lastAccessedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case url
        case title
        case content
        case contentType
        case tags
        case createdAt
        case lastAccessedAt
    }
}

enum ContentType: String, Codable {
    case article, passage, tweet, image, unknown
}

struct Tag: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
}
