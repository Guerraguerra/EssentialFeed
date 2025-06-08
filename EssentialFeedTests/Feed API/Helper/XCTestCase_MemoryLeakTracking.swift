//
//  SCTestCase_MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Alex Guerra on 6/8/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Pontential memory leak.", file: file, line: line)
        }
    }
}
