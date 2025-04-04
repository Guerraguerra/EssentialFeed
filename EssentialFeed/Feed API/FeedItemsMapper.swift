//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 4/2/25.
//

import Foundation

class FeedItemMapper{
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map{ $0.feedItem }
        }
    }

    private struct Item : Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map({$0.feedItem})
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse)  -> RemoteFeedLoader.Result {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.feed)
    }
}
