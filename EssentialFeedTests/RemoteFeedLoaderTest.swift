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
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com/feed")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in
            capturedError = error
        }
        XCTAssertEqual(capturedError, .conectivity)
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
        var requestedURLs = [URL]()
        var error: Error?
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }

}
