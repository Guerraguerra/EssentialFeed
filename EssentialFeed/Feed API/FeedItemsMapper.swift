//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 4/2/25.
//

import Foundation

internal struct RemoteFeedItem : Decodable{
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

class FeedItemMapper{
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
   /* static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items
    }*/
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws  -> [RemoteFeedItem] {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
