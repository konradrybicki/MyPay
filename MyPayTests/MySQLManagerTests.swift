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
        
        let accountNumber = "58525434552955252827743282"
        let amount: Double = 200_000
        
        let topUp = TopUp(target: accountNumber, amount)
        
        XCTAssertNoThrow(try MySQLManager.insert(topUp: topUp))
    }
    
    func testSelectAccountNumber() throws {
        
        // given
        let userId: Int16 = 1
        
        // when
        let accountNumber = try MySQLManager.selectAccountNumber(forUserWith: userId)
        
        // then
        XCTAssertEqual(accountNumber, "58525434552955252827743282")
    }
}
