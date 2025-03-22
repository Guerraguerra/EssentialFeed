//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/12/25.
//


public protocol HTTPClient{
    func get(from url: URL, completion : @escaping (Error?, HTTPURLResponse?)-> Void)
}

public class RemoteFeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void){
        client.get(from: url) { error, response in
            if error != nil {
                completion(.conectivity)
            }
            else {
                completion(.invalidData)
            }
        }
    }
}
