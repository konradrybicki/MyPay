//
//  MySQLManagerTests.swift
//  MyPayTests
//
//  Created by Konrad Rybicki on 22/09/2021.
//

import XCTest

@testable import MyPay

class MySQLManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testInsertTopUp() throws {
        
        // given
        
        let accountNumber = "58525434552955252827743282"
        let amount: Double = 200_000
        
        let topUp = TopUp(target: accountNumber, amount)
        
        // when, then
        
        XCTAssertNoThrow(try MySQLManager.insert(topUp: topUp))
    }
}
