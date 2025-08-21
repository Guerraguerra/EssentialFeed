//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 8/14/25.
//

import Foundation

public struct LocalFeedImage : Equatable{
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
