//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 3/12/25.
//

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
        client.get(from: url) { [weak self] result in
            //This line of code is garantee that if the
            //RemoteFeedLoader is deallocated the rest of
            //the code will not be executed
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, response))
           /*     if let items = try? FeedItemMapper.map(data, response){
                    completion(.success(items))
                }
                else{
                    completion(.failure(.invalidData))
                }*/
            case .failure:
                completion(.failure(.conectivity))
            }
        }
    }
    
    
}




