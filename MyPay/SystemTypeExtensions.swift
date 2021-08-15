//
//  SystemTypeExtensions.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

import Foundation

extension Int {
    
    /// Optionally returns an ASCII character from an intiger value
    
    public func asAsciiCharacter() -> Character? {
        
        guard let unicodeScalar = UnicodeScalar(self) else {
            print("Error inside Int.asAsciiCharacter() - UnicodeScalar parsing failure for value \(self)")
            return nil
        }
        
        return Character(unicodeScalar)
    }
}
