//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/3/25.
//

public struct FeedItem : Equatable{
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
