//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Alex Guerra on 4/2/25.
//

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, completion : @escaping (HTTPClientResult)-> Void)
}
