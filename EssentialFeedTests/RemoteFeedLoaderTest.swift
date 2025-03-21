//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Alex Guerra on 3/6/25.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com/feed")!
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com/feed")!
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        sut.load{ _ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.conectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0)}
            client.complete(withStatusCode: 400, at: index)
        
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Herpers
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs : [URL] {
            return messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
         func complete(with error: Error, at index: Int = 0) {
             messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(response))
       }
    }

}
