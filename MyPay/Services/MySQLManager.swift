//
//  MySQLDbService.swift
//  MyPay
//
//  Created by Konrad Rybicki on 10/08/2021.
//

import MySQL

/// Is responisble for all database-related operations (i.e. connection establishment, data insertion or uniqueness checking)

public class MySQLManager {
    
    /// Inserts all 'user' object's field values into the database and, after the insertion is complete, retrieves user's id
    
    public static func insert(user: User) throws -> Int {
        
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
        
        // sql statement execution (user insertion)
        
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
        
        // sql statement execution (id selection)
        
        let userId: Int
        
        do {
            
            let preparedStatement = try connection.prepare("select max(UserID) from Users;")
            
            // whole result
            let result: Result = try preparedStatement.query([])
            
            // single row (MySQL.Row format)
            let mysqlRow: MySQL.Row = result.rows[0]
            
            // single row (Swift Dictionary)
            let swiftRow: [String : Any] = mysqlRow.values
            
            // last inserted user id (dict value)
            
            let key = "max(UserID)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.insert(user) - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            // last inserted user id (Any->Int downcasting)
            guard let maxUserID = value as? Int else {
                print("Error inside MySQLManager.insert(user) - Any->Int downcasting failure")
                throw DatabaseError.interactionError
            }
            
            // final result
            userId = maxUserID
        }
        catch DatabaseError.interactionError {
            throw DatabaseError.interactionError
        }
        catch {
            print(error)
            throw DatabaseError.interactionError
        }

        // connection closing
        
        try closeConnection(connection)
        
        // user id return
        
        return userId
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
            
            let result = try preparedStatement.query([salt])
            
            let mysqlRow = result.rows[0]
            
            let swiftRow = mysqlRow.values
            
            let key = "count(SecurityCodeSalt)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isSecurityCodeSaltUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int64 else {
                print("Error inside MySQLManager.isSecurityCodeSaltUnique() - Any->Int64 downcasting failure")
                throw DatabaseError.interactionError
            }
            
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
            
            let mysqlRow = result.rows[0]
            
            let swiftRow = mysqlRow.values
            
            let key = "count(AccountNumber)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isAccountNumberUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int64 else {
                print("Error inside MySQLManager.isAccountNumberUnique() - Any->Int64 downcasting failure")
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
            
            let mysqlRow = result.rows[0]
            
            let swiftRow = mysqlRow.values
            
            let key = "count(CardNumber)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isCardNumberUnique() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int64 else {
                print("Error inside MySQLManager.isCardNumberUnique() - Any->Int64 downcasting failure")
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
    
    /// Checks if there is any active account in the database, with the same area code and phone number as given
    
    public static func isTelephoneNumberUniqueForAnActiveAccount(_ areaCode: String, _ phoneNumber: String) throws -> Bool {
        
        let connection = try establishConnection()
        
        var isTelephoneNumberUnique: Bool
        
        do {
            
            let preparedStatement = try connection.prepare("""
                select count(*)
                from Users
                where AreaCode = ? and
                      PhoneNumber = ? and
                      ProfileStatus = 'Active';
            """)
            
            let result = try preparedStatement.query([areaCode, phoneNumber])
            
            let mysqlRow = result.rows[0]
            
            let swiftRow = mysqlRow.values
            
            let key = "count(*)"
            
            guard let value = swiftRow[key] else {
                print("Error inside MySQLManager.isTelephoneNumberUniqueForAnActiveAccount() - dict value access failure for key '\(key)'")
                throw DatabaseError.interactionError
            }
            
            guard let count = value as? Int64 else {
                print("Error inside MySQLManager.isTelephoneNumberUniqueForAnActiveAccount() - Any->Int64 downcasting failure")
                throw DatabaseError.interactionError
            }
            
            if count == 0 {
                isTelephoneNumberUnique = true
            }
            else {
                isTelephoneNumberUnique = false
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
        
        return isTelephoneNumberUnique
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