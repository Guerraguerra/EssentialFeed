//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/4/25.
//

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
