//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/3/25.
//

public struct FeedItem : Equatable{
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
