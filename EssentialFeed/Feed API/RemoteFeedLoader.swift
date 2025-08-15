//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/12/25.
//

public class RemoteFeedLoader : FeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void){
        client.get(from: url) { [weak self] result in
            //This line of code is garantee that if the
            //RemoteFeedLoader is deallocated the rest of
            //the code will not be executed
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion( RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.conectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, from: response)
            return .success(items.toModels())
        }
        catch {
            return .failure(error)
        }
    }
    
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)}
    }
}


