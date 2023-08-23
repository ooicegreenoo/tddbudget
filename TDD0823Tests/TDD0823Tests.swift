//
//  TDD0823Tests.swift
//  TDD0823Tests
//
//  Created by Jessica-cathay on 2023/8/23.
//

import XCTest
@testable import TDD0823

class Tennis {
    
    func score() -> String {
        return "love all"
    }
    
    func first得分() {
        
    }
}

final class TDD0823Tests: XCTestCase {
    var tennis: Tennis!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        tennis = Tennis()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_love_all() {
        XCTAssertEqual(tennis.score(), "love all")
    }
    
    func test_first_fifteen_love() {
        tennis.first得分()
        XCTAssertEqual(tennis.score(), "fifteen love")
    }

}
