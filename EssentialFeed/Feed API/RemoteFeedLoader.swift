//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/12/25.
//


public protocol HTTPClient{
    func get(from url: URL)
}

public class RemoteFeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(){
        client.get(from: url)
    }
}
