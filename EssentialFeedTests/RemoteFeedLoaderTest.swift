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
        
        expect(sut, toCompleteWith: .failure(.conectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: 400, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJson = Data("{\"item\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJSONList() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(
            id: UUID(),
            imageURL: URL(string: "http://item1url.com")!
        )
        let item2 = FeedItem(
            id: UUID(),
            description: "Description for item2",
            location: "item2 location",
            imageURL: URL(string: "http://item2url.com")!
        )
        
        let item1json = [
            "id" : item1.id.uuidString,
            "image" : "http://item1url.com"
        ]
        
        let item2json = [
            "id" : item2.id.uuidString,
            "description" : item2.description,
            "location" : item2.location,
            "image" : "http://item2url.com"
        ]
        
        let itemsJson = [
            "items" : [item1json, item2json]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    // MARK: - Herpers
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0)}
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line:  line)
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
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
       }
    }

}
