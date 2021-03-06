//
//  TopUp.swift
//  MyPay
//
//  Created by Konrad Rybicki on 21/09/2021.
//

import Foundation

/// Defines a database-related account top-up structure

public class TopUp: Transaction {
    
    public var accountNumber: String
    public var amount: Double
    public var transactionDate: Date
    
    public init(target accountNumber: String, _ amount: Double) {
        self.accountNumber = accountNumber
        self.amount = amount
        self.transactionDate = Date()
    }
    
    /// Calls MySQLManager's insert(topUp) method, passing current instance as an argument to the function
    
    public func register() throws {
        try MySQLManager.insert(topUp: self)
    }
}
