//
//  VirtualCard.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

import Foundation

public class VirtualCard {
    
    /// Defines a self-generating virtual card database structure
    
    public var cardNumber: String
    public var accountNumber: String
    public var expirationMonth: String
    public var expirationYear: String
    public var cvv: String
    
    public init(forAccountWithNumber accountNumber: String) {
        self.cardNumber = generateUniqueCardNumber()
        self.accountNumber = accountNumber
        self.expirationMonth = getExpirationMonth()
        self.expirationYear = getExpirationYear()
        self.cvv = generateCvv()
    }
    
    private func generateUniqueCardNumber() -> String {
        
        /// Generates a 16 digit unique card number
        
        var cardNumber: String
        
        repeat {
            
            cardNumber = ""
            
            for _ in 0..<16 {
                let randomDigit = Int.random(in: 0...9)
                cardNumber.append(String(randomDigit))
            }
            
        } while isCardNumberUnique(cardNumber) == false
        
        return cardNumber
    }
    
    private func getExpirationMonth() -> String {
        
        /// Returns current month as a 2 digit string
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate: String = dateFormatter.string(from: Date())
        let currentMonth: Substring = currentDate[5...6]
        
        return String(currentMonth)
    }
    
    private func getExpirationYear() -> String {
        
        /// Returns current year incremented by 4 as a 4 digit string
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate: String = dateFormatter.string(from: Date())
        let currentYear: Substring = currentDate[0...3]
        
        currentYear = Int!(String(currentYear))
        currentYear += 4
        
        return String(currentYear)
    }
    
    private func generateCvv() -> String {
        
        /// Generates a 3 digit non-unique cvv code
        
        var cvv: String = ""
        
        for _ in 0..<3 {
            let randomDigit = Int.random(in: 0...9)
            cvv.append(String(randomDigit))
        }
        
        return cvv
    }
}
