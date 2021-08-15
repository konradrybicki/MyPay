//
//  MySQLDbService.swift
//  MyPay
//
//  Created by Konrad Rybicki on 10/08/2021.
//

import MySQL

//MARK: - MySQLManager

/// Is responisble for all database operations (i.e. connection establishment, data insertion or uniqueness checking)

public class MySQLManager {
    
    /// Inserts all 'user' object's field values into the database
    
    public static func insert(user: User) throws {
        
        // connection establishment
        
        let connection: MySQL.Connection = try establishConnection()
        
        // data "decapsulation"
        
        let firstName = user.firstName
        let lastName = user.lastName
        let areaCode = user.areaCode
        let phoneNumber = user.phoneNumber
        let scHash = user.securityCodeHash
        let scSalt = user.securityCodeSalt
        let birthDate = user.birthDate
        
        // sql statement execution
        
        do {
            let preparedStatement: MySQL.Statement = try connection.prepare("""
                insert into Users(
                    FirstName,
                    LastName,
                    AreaCode,
                    PhoneNumber,
                    SecurityCodeHash,
                    SecurityCodeSalt,
                    BirthDate,
                    ProfileStatus
                ) values(?, ?, ?, ?, ?, ?, ?, 'Active');
            """)
            
            try preparedStatement.exec([firstName, lastName, areaCode, phoneNumber, scHash, scSalt, birthDate])
        }
        catch {
            print(error)
            throw DatabaseError.dataSavingFailure
        }
        
        // connection closing
        
        try closeConnection(connection)
    }
    
    /// Inserts all 'account' object's field values into the database
    
    public static func insert(_ account: Account) throws {
        
        let connection = try establishConnection()
        
        let accountNumber = account.accountNumber
        let userId = account.userId
        let balance = account.balance
        
        do {
            let preparedStatement = try connection.prepare("insert into Accounts values(?, ?, ?);")
            try preparedStatement.exec([accountNumber, userId, balance])
        }
        catch {
            print(error)
            throw DatabaseError.dataSavingFailure
        }
        
        try closeConnection(connection)
    }
    
    /// Inserts all 'virtualCard' object's field values into the database
    
    public static func insert(_ virtualCard: VirtualCard) throws {
        
        let connection = try establishConnection()
        
        let cardNumber = virtualCard.cardNumber
        let accountNumber = virtualCard.accountNumber
        let expirationMonth = virtualCard.expirationMonth
        let expirationYear = virtualCard.expirationYear
        let cvv = virtualCard.cvv
        
        do {
            let preparedStatement = try connection.prepare("insert into VirtualCards values(?, ?, ?, ?, ?);")
            try preparedStatement.exec([cardNumber, accountNumber, expirationMonth, expirationYear, cvv])
        }
        catch {
            print(error)
            throw DatabaseError.dataSavingFailure
        }
        
        try closeConnection(connection)
    }
}

extension MySQLManager {
    
    /// Checks if there is any salt in the database, with the same value as given
    
    public static func isSecurityCodeSaltUnique(_ salt: String) throws -> Bool {
        
        let connection = try establishConnection()
        
        var isSaltUnique: Bool
        
        do {
            
            let preparedStatement = try connection.prepare("""
                select count(SecurityCodeSalt)
                from Users
                where SecurityCodeSalt = ?;
            """)
            
            // whole result
            let result: Result = try preparedStatement.query([salt])
            
            // single row (MySQL.Row format)
            let mysqlRow: MySQL.Row = try result.readRow()!
            
            // single row (Swift Dictionary)
            let swiftRow: [String : Any] = mysqlRow.values
            
            // count (dict value)
            
            let key = "count(SecurityCodeSalt)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isSecurityCodeSaltUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            // count (Any->Int downcasting)
            guard let count = value as? Int else {
                print("Error inside MySQLManager.isSecurityCodeSaltUnique() - Any->Int downcasting failure")
                throw DatabaseError.interactionError
            }
            
            // final result
            if count == 0 {
                isSaltUnique = true
            }
            else {
                isSaltUnique = false
            }
        }
        catch DatabaseError.interactionError {
            throw DatabaseError.interactionError
        }
        catch {
            print(error)
            throw DatabaseError.interactionError
        }
        
        try closeConnection(connection)
        
        return isSaltUnique
    }
    
    /// Checks if there is any account in the database, with the same number as given
    
    public static func isAccountNumberUnique(_ accountNumber: String) throws -> Bool {
        
        let connection = try establishConnection()
        
        var isAccountNumberUnique: Bool
        
        do {
            
            let preparedStatement = try connection.prepare("""
                select count(AccountNumber)
                from Accounts
                where AccountNumber = ?;
            """)
            
            let result = try preparedStatement.query([accountNumber])
            
            let mysqlRow = try result.readRow()!
            
            let swiftRow = mysqlRow.values
            
            let key = "count(AccountNumber)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isAccountNumberUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int else {
                print("Error inside MySQLManager.isAccountNumberUnique() - Any->Int downcasting failure")
                throw DatabaseError.interactionError
            }
            
            if count == 0 {
                isAccountNumberUnique = true
            }
            else {
                isAccountNumberUnique = false
            }
        }
        catch DatabaseError.interactionError {
            throw DatabaseError.interactionError
        }
        catch {
            print(error)
            throw DatabaseError.interactionError
        }
        
        try closeConnection(connection)
        
        return isAccountNumberUnique
    }
    
    /// Checks if there is any virtual card in the database, with the same number as given
    
    public static func isCardNumberUnique(_ cardNumber: String) throws -> Bool {
        
        let connection = try establishConnection()
        
        var isCardNumberUnique: Bool
        
        do {
            
            let preparedStatement = try connection.prepare("""
                select count(CardNumber)
                from VirtualCards
                where CardNumber = ?;
            """)
            
            let result = try preparedStatement.query([cardNumber])
            
            let mysqlRow = try result.readRow()!
            
            let swiftRow = mysqlRow.values
            
            let key = "count(CardNumber)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isCardNumberUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int else {
                print("Error inside MySQLManager.isCardNumberUnique() - Any->Int downcasting failure")
                throw DatabaseError.interactionError
            }
            
            if count == 0 {
                isCardNumberUnique = true
            }
            else {
                isCardNumberUnique = false
            }
        }
        catch DatabaseError.interactionError {
            throw DatabaseError.interactionError
        }
        catch {
            print(error)
            throw DatabaseError.interactionError
        }
        
        try closeConnection(connection)
        
        return isCardNumberUnique
    }
}

extension MySQLManager {
    
    /// Establishes a database connection, returning an appropriate object
    
    private static func establishConnection() throws -> MySQL.Connection {
        
        let connection: MySQL.Connection
        
        do {
            connection = try MySQL.Connection(
                host: "mypay.cba.pl",
                user: "konradrybicki",
                password: "MySQLPass123!",
                database: "konradrybicki",
                port: 3306
            )
            
            try connection.open()
        }
        catch {
            print(error)
            throw DatabaseError.connectionFailure
        }
        
        return connection
    }
    
    /// Closes a database connection via object reference
    
    private static func closeConnection(_ connection: MySQL.Connection) throws {
        
        do {
            try connection.close()
        }
        catch {
            print(error)
            throw DatabaseError.connectionFailure
        }
    }
}

//MARK: - DatabaseError

/// User-defined error type

public enum DatabaseError: Error {
    case connectionFailure
    case dataSavingFailure
    case interactionError
}
