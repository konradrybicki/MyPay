//
//  TopUp.swift
//  MyPay
//
//  Created by Konrad Rybicki on 21/09/2021.
//

import Foundation

public class TopUp: Transaction {
    
    public var accountNumber: String
    public var amount: Double
    public var transactionDate: Date
    
    public init(target accountNumber: String, _ amount: Double) {
        self.accountNumber = accountNumber
        self.amount = amount
        self.transactionDate = Date()
    }
    
    public func register() throws {
        
        // ..
        
    }
}
