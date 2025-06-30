//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Alex Guerra on 6/24/25.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    class LocalFeedLoader{
        private let store: FeedStore
        private let currentDate: () -> Date
        init(store: FeedStore, timestamp: @escaping () -> Date){
            self.store = store
            self.currentDate = timestamp
        }
        
        func save(_ items: [FeedItem]){
            store.deleteCachedFeed { [unowned self] error in
                if error == nil {
                    self.store.insert(items, timestamp: self.currentDate())
                }
            }
        }
        
        
    }
    
    class FeedStore{
        typealias DeletionCompletion = (Error?) -> Void
        var deleteCacheFeedCallCount = 0
        var insertionCallCount = 0
        var insertions = [(items: [FeedItem], timestamp: Date)]()
        
        private var deletionCompletions = [DeletionCompletion]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion){
            deleteCacheFeedCallCount += 1
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0){
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0){
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date){
            insertionCallCount += 1
            insertions.append((items, timestamp))
        }
    }
    
    func test_init_DoesNotDeleteCacheUponCreation(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCasheDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertionCallCount, 0)
    }
    
    func test_save_requestCacheInsertionOnSuccessfulDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertionCallCount, 1)
    }
    
    func test_save_requestCacheInsertionWithTimestampOnSuccessfulDeletion(){
        
        // Save choice here is to inject this timestamp to the LocalFeedLoader
        //This can be done using a protocol or a clousure
        let timestamp = Date()
        
        let (sut, store) = makeSUT(currentDate : {timestamp})
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, timestamp: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: "Any description",
            location: "Any location",
            imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "Any error", code: 0)
    }

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
