//
//  Transaction.swift
//  MyPay
//
//  Created by Konrad Rybicki on 21/09/2021.
//

import Foundation

/// An abstract layer for all transaction types (top-ups, transactions and virtual card payments)

public protocol Transaction {
    
    var amount: Double { get set }
    var transactionDate: Date { get set }
    
    func register() throws
}
