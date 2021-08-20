//
//  ValidationService.swift
//  MyPay
//
//  Created by Konrad Rybicki on 20/08/2021.
//

import Foundation

/// Is responsible for data validation, validating data either separately (ex.: birth date, area code, phone number) or together (ex.: area code and phone number combination)

public class ValidationService {
    
    /// Checks if name's length is anywhere between 1 and 20 and contains ASCII charset upercased/lowercased letters only
    
    public static func isNameValid(_ name: String) -> Bool {
        
        // submethods - length
        
        func isNameLengthValid() -> Bool {
            (1...20).contains(name.count)
        }
        
        // submethods - permitted characters
        
        func isUpperCasedLetter(_ character: Character) -> Bool {
            (65...90).contains(character.asciiValue!)
        }
        
        func isLowerCasedLetter(_ character: Character) -> Bool {
            (97...122).contains(character.asciiValue!)
        }
        
        // submethods - character validation
        
        func isValid(_ character: Character) -> Bool {
            
            if character.isASCII == false {
                return false
            }
            else {
                if isUpperCasedLetter(character) == true ||
                   isLowerCasedLetter(character) == true {
                    
                    return true
                }
                else {
                    return false
                }
            }
        }
        
        // actual validation
        
        if isNameLengthValid() == false {
            return false
        }
        
        for character in name {
            if isValid(character) == false {
                return false
            }
        }
        
        return true
    }
    
    /// Checks if user is minimum 16 years old
    
    public static func isBirthDateValid(_ birthDate: String) -> Bool {
        
        // birth year
        
        let birthYear_str = String(birthDate.prefix(4))
        let birthYear_int = Int(birthYear_str)!
        
        // current year
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = dateFormatter.string(from: Date())
        
        let currentYear_str = String(currentDate.prefix(4))
        let currentYear_int = Int(currentYear_str)!
        
        // users age calculation
        
        let usersAge = currentYear_int - birthYear_int
        
        if usersAge >= 16 {
            return true
        }
        else {
            return false
        }
    }
    
    /// Checks if area code's length is anywhere between 1 and 5
    
    public static func isAreaCodeValid(_ areaCode: String) -> Bool {
        (1...5).contains(areaCode.count)
    }
    
    /// Checks if phone number's length is anywhere between 1 and 10
    
    public static func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        (1...10).contains(phoneNumber.count)
    }
}
