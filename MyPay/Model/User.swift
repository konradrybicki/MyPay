//
//  User.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

public class User {
    
    /// Defines user's structure (according to the database/interface structure) as well as the behaviour
    
    // personal data (initialized with the object)
    
    private(set) var firstName: String
    private(set) var lastName: String
    private(set) var birthDate: String
    private(set) var areaCode: String
    private(set) var phoneNumber: String
    
    // security code (initialized manually)
    
    public var securityCodeHash: String = ""
    public var securityCodeSalt: String = ""
    
    public init(firstName: String, lastName: String, birthDate: String, areaCode: String, phoneNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.areaCode = areaCode
        self.phoneNumber = phoneNumber
    }
    
    public func register() {
        
        // TODO: data generation (account, virtual card)
        
        // TODO: database interaction
        
    }
}
