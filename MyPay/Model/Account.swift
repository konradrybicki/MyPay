//
//  Account.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

public class Account {
    
    /// Defines a self-generating account database structure
    
    public var accountNumber: String
    public var userId: Int
    public var balance: Double
    
    public init(forUserWithId userId: Int) {
        self.accountNumber = generateUniqueAccountNumber()
        self.userId = userId
        self.balance = 0
    }
    
    private func generateUniqueAccountNumber() -> String {
        
        /// Generates a 26 digit unique account number
        
        var accountNumber: String
        
        repeat {
            
            accountNumber = ""
            
            for _ in 0..<26 {
                let randomDigit = Int.random(in: 0...9)
                accountNumber.append(String(randomDigit))
            }
            
        } while isAccountNumberUnique(accountNumber) == false
        
        return accountNumber
    }
}
