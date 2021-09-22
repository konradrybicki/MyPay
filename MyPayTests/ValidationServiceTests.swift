//
//  ValidationServiceTests.swift
//  MyPayTests
//
//  Created by Konrad Rybicki on 22/09/2021.
//

import XCTest

@testable import MyPay

class ValidationServiceTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    // boundary conditions - "will work for sure"
    
    func testIsTopUpAmountValid_whenAmountIsEqualTo50() {
        
        //given
        let topUpAmount: Double = 50
        
        // when
        let topUpAmountValid = ValidationService.isTopUpAmountValid(topUpAmount)
        
        // then
        XCTAssertTrue(topUpAmountValid)
    }
    
    func testIsTopUpAmountValid_whenAmountIsEqualToOneMillion() {
        
        let topUpAmount: Double = 1_000_000
        
        let topUpAmountValid = ValidationService.isTopUpAmountValid(topUpAmount)
        
        XCTAssertTrue(topUpAmountValid)
    }
    
    func testIsTopUpAmountValid_whenAmountIsEqualTo500000() {
        
        let topUpAmount: Double = 500_000
        
        let topUpAmountValid = ValidationService.isTopUpAmountValid(topUpAmount)
        
        XCTAssertTrue(topUpAmountValid)
    }
    
    // boundary conditions - "won't work for sure"
    
    func testIsTopUpAmountValid_whenAmountIsEqualToZero() {
        
        let topUpAmount: Double = 0
        
        let topUpAmountValid = ValidationService.isTopUpAmountValid(topUpAmount)
        
        XCTAssertFalse(topUpAmountValid)
    }
    
    func testIsTopUpAmountValid_whenAmountIsEqualToTwoMillion() {
        
        let topUpAmount: Double = 2_000_000
        
        let topUpAmountValid = ValidationService.isTopUpAmountValid(topUpAmount)
        
        XCTAssertFalse(topUpAmountValid)
    }
}
