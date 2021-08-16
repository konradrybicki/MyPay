//
//  CryptoService.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

import CryptoSwift //This product includes software developed by the "Marcin Krzyzanowski" (http://krzyzanowskim.com/).

/// Is responsible for cryptographic operations (i.e. security code hashing or salt generation)

public class CryptoService {
    
    /// Generates a 64 character sha256 hash, using given securitycode as well as the salt
    
    public static func hash(securityCode: String, saltingWith salt: String) -> String {
        
        let securityCode_salted = salt + securityCode
        let digest = securityCode_salted.sha256()
        
        return digest
    }
    
    /// Generates a 64 character String of random ascii signs in a certain range
    
    public static func generateSalt() throws -> String {
        
        var salt: String
        var isSaltUnique: Bool
        
        repeat {
            
            salt = ""
            
            for _ in 0..<64 {
                
                let randomAsciiIndexInRange = Int.random(in: 33...126)
                
                guard let randomAsciiCharacterInRange: Character = randomAsciiIndexInRange.asAsciiCharacter() else {
                    throw DataGenerationError.def
                }
                
                salt.append(randomAsciiCharacterInRange)
            }
            
            isSaltUnique = try MySQLManager.isSecurityCodeSaltUnique(salt)
            
        } while isSaltUnique == false
        
        return salt
    }
}
