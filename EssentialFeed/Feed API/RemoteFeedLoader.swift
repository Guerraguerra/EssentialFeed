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
            case let .success(data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
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
