//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 6/10/25.
//

import Foundation

public class URLSessionHTTPClient : HTTPClient{
    private let session: URLSession
    
    struct UnexpectedValuesRepresentation: Error{}
    
    public init(session: URLSession = .shared){
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        //let url = URL(string: "http://wrong-url.com")!  This line is to make the test test_getFromURL_performGETRequestWithURL fail
        session.dataTask(with: url) { data, response, error in
            if let error = error{
                completion(.failure(error))
            } else if let receivedData = data, let receivedresponse = response as? HTTPURLResponse{
                completion(.success(receivedData, receivedresponse))
            }else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
