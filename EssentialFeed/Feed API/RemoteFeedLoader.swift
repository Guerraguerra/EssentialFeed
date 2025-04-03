//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/12/25.
//

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, completion : @escaping (HTTPClientResult)-> Void)
}

public class RemoteFeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public enum Result : Equatable{
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void){
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let items = try? FeedItemMapper.map(data, response){
                    completion(.success(items))
                }
                else{
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.conectivity))
            }
        }
    }
}

private class FeedItemMapper{
    
    private struct Root: Decodable {
        let items: [Item]
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
}


