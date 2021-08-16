//
//  Account.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

/// Defines a database-related bank account structure

public class Account {
    
    private(set) var accountNumber: String = ""
    private(set) var userId: Int = -1
    public var balance: Double = 0
    
    public init(forUserWithId userId: Int) throws {
        self.accountNumber = try generateAccountNumber()
        self.userId = userId
    }
    
    /// Returns a 26 digit String, representing a database-unique account number
    
    private func generateAccountNumber() throws -> String {
        
        var accountNumber: String
        var isAccountNumberUnique: Bool
        
        repeat {
            
            accountNumber = ""
            
            for _ in 0..<26 {
                let randomDigit = Int.random(in: 0...9)
                accountNumber.append(String(randomDigit))
            }
            
            isAccountNumberUnique = try MySQLManager.isAccountNumberUnique(accountNumber)
            
        } while isAccountNumberUnique == false
        
        return accountNumber
    }
}
