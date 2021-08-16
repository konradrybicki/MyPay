//
//  User.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

/// Defines a database-related user structure

public class User {
    
    // personal data (initialized with the object, in the RegistrationFormViewController)
    private(set) var firstName: String
    private(set) var lastName: String
    private(set) var birthDate: String
    private(set) var areaCode: String
    private(set) var phoneNumber: String
    
    // security code data (initialized manually, in the SCConfigScreenViewController)
    public var securityCodeHash: String = ""
    public var securityCodeSalt: String = ""
    
    // id (initialized right after user's data gets inserted into the database)
    private var userId: Int = -1
    
    public init(firstName: String, lastName: String, birthDate: String, areaCode: String, phoneNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.areaCode = areaCode
        self.phoneNumber = phoneNumber
    }
    
    /// Triggers the most of registration mechanisms (user database insertion, account and virtual card generation, account and virtual card database insertion) using appropriate classes (MySQLManager, Account, VirtualCard)
    
    public func register() throws {
        
        // user database insertion
        self.userId = try MySQLManager.insert(user: self)
        
        // account and virtual card generation
        let account = try Account(forUserWithId: userId)
        let virtualCard = try VirtualCard(forAccountWithNumber: account.accountNumber)
        
        // account and virtual card database insertion
        try MySQLManager.insert(account)
        try MySQLManager.insert(virtualCard)
    }
}
