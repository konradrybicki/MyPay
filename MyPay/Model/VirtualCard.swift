//
//  VirtualCard.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

import Foundation

/// Defines a database-related virtual card structure

public class VirtualCard {
    
    private(set) var cardNumber = ""
    private(set) var accountNumber = ""
    private(set) var expirationMonth = ""
    private(set) var expirationYear = ""
    private(set) var cvv = ""
    
    public init(forAccountWithNumber accountNumber: String) throws {
        self.cardNumber = try generateCardNumber()
        self.accountNumber = accountNumber
        self.expirationMonth = getExpirationMonth()
        self.expirationYear = try getExpirationYear()
        self.cvv = generateCvv()
    }
    
    /// Returns a 16 digit String, representing a database-unique virtual card number
    
    private func generateCardNumber() throws -> String {
        
        var cardNumber: String
        var isCardNumberUnique: Bool
        
        repeat {
            
            cardNumber = ""
            
            for _ in 0..<16 {
                let randomDigit = Int.random(in: 0...9)
                cardNumber.append(String(randomDigit))
            }
            
            isCardNumberUnique = try MySQLManager.isCardNumberUnique(cardNumber)
            
        } while isCardNumberUnique == false
        
        return cardNumber
    }
    
    /// Returns a two-digit String, representing a virtual card's expiration month (current month) in a numeric format (i.e. January - '01')
    
    private func getExpirationMonth() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // whole date
        
        let currentDate: String = dateFormatter.string(from: Date())
        
        // month only
        
        let startIndex: String.Index = currentDate.index(currentDate.startIndex, offsetBy: 5)
        let endIndex: String.Index = currentDate.index(currentDate.startIndex, offsetBy: 6)
        
        let expirationMonth = String(currentDate[startIndex...endIndex])
        
        return expirationMonth
    }
    
    /// Returns a four-digit String, representing a virtual card's expiration year (current year + 4)
    
    private func getExpirationYear() throws -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = dateFormatter.string(from: Date())
        
        // current year (string->int)
        
        let currentYear_str = String(currentDate.prefix(4))
        
        guard let currentYear_int = Int(currentYear_str) else {
            print("Error inside VirtualCard->getexpirationYear() - String->Int parsing failure")
            throw DataGenerationError.def
        }
        
        // expiration year (int->string)
        
        let expirationYear_int = currentYear_int + 4
        let expirationYear_str = String(expirationYear_int)
        
        return expirationYear_str
    }
    
    /// Returns a three-digit String, representing a virtual card's cvv code
    
    private func generateCvv() -> String {
        
        var cvv: String = ""
        
        for _ in 0..<3 {
            let randomDigit = Int.random(in: 0...9)
            cvv.append(String(randomDigit))
        }
        
        return cvv
    }
}
