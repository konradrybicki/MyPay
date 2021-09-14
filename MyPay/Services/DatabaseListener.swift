//
//  DatabaseListener.swift
//  MyPay
//
//  Created by Konrad Rybicki on 13/09/2021.
//

import Foundation
import UIKit
import MySQL

/// Listens for database events, such as an account balance update and informs the delegate upon them

public class DatabaseListener {
    
    public var delegate: DatabaseListenerDelegate!
    
    private var shouldListen: Bool! // controlls all listening loops
}

extension DatabaseListener {
    
    /// Moves to the background thread, connects with the database and launches an account balance selection loop to capture a balance update event. In such case, moves back to a main thread to inform the delegate and continues listening on the background thread
    
    public func listenForAccountBalanceUpdate() -> Void {
        
        // launching code on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.shouldListen = true
            
            // (client and database stored account balance)
            var accountBalance_client = GlobalVariables.loggedUsersAccountBalance!
            var accountBalance_database: String = ""
            
            // (logged user's id, needed for account balance selection)
            let loggedUsersId = GlobalVariables.loggedUsersId!
            
            do {
                
                // database connection establishment
                let connection = try self.establishConnection()
                
                // account balance update checking loop
                while self.shouldListen {
                    
                    accountBalance_database = try self.selectAccountBalance(forUserWith: loggedUsersId, usingConnection: connection)
                    
                    if accountBalance_database != accountBalance_client {
                    
                        // main thread delegation (update captured)
                        DispatchQueue.main.async {
                            self.delegate.databaseListener(capturedAccountBalanceUpdateEvent: accountBalance_database)
                        }
                        
                        // variable update
                        accountBalance_client = accountBalance_database
                    }
                    
                    // interval between iterations (1 second)
                    sleep(1)
                }
                
                // database connection closing
                try self.closeConnection(connection)
            }
            catch {
                
                if error as! DatabaseError == .connectionFailure {
                    
                    // moving back to a main thread (UI interaction)
                    DispatchQueue.main.async {
                        self.handleErrorFromAnyController(error)
                    }
                }
                else if error as! DatabaseError == .dataLoadingFailure {
                    
                    DispatchQueue.main.async {
                        self.handleErrorFromAnyController(error)
                    }
                }
            }
        }
    }
    
    /// Selects specified user's account balance from the database, using existing database connection
    
    private func selectAccountBalance(forUserWith loggedUsersId: Int16, usingConnection connection: MySQL.Connection) throws -> String {
        
        let balance: String
        
        do {
            
            let preparedStatement = try connection.prepare("select Balance from Accounts where UserID = ?;")
            
            let result = try preparedStatement.query([loggedUsersId])
            
            let mysqlRow = result.rows[0]
            
            let swiftRow: [String : Any] = mysqlRow.values
            
            let key = "Balance"
            
            guard let value = swiftRow[key] else {
                print("Error inside DatabaseListener.selectAccountBalance() - dict value access failure for key '\(key)'")
                throw DatabaseError.dataLoadingFailure
            }
            
            guard let _balance = value as? String else {
                print("Error inside DatabaseListener.selectAccountBalance() - Any->String downcasting failure")
                throw DatabaseError.dataLoadingFailure
            }
            
            balance = _balance
        }
        catch DatabaseError.dataLoadingFailure {
            throw DatabaseError.dataLoadingFailure
        }
        catch {
            print(error)
            throw DatabaseError.dataLoadingFailure
        }
        
        return balance
    }
}

extension DatabaseListener {
    
    /// Stops all listening loops
    
    public func stopListening() -> Void {
        shouldListen = false
    }
}

extension DatabaseListener {
    
    /// Establishes a database connection, returning an appropriate object
    
    private func establishConnection() throws -> MySQL.Connection {
        
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
    
    private func closeConnection(_ connection: MySQL.Connection) throws {
        
        do {
            try connection.close()
        }
        catch {
            print(error)
            throw DatabaseError.connectionFailure
        }
    }
}
    
extension DatabaseListener {
    
    /// Identifies the top (last presented) view controller and uses it to display an error message
    
    private func handleErrorFromAnyController(_ error: Error) {
        
        // error communicate preparation
        
        var errorCommunicate = ""
        
        if error as! DatabaseError == .connectionFailure {
            errorCommunicate = "We're having problems with the connection\n\nYour account's balance might not refresh automatically"
        }
        else if error as! DatabaseError == .dataLoadingFailure {
            errorCommunicate = "We're having problems\n\nYour account's balance will most probably not refresh automatically\n\nPlease be patient while we attempt to resolve the issue"
        }
        
        // top vc identification
        
        var currentVC = UIApplication.shared.keyWindow!.rootViewController!
        
        while let presentedVC = currentVC.presentedViewController {
            currentVC = presentedVC
        }
        
        let topVC = currentVC
        
        // error communicate display
        
        let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
        topVC.present(communicateVC, animated: true, completion: nil)
    }
}

/// Informs the delegate about an event captured by a DatabaseListener, such as an account balance update

public protocol DatabaseListenerDelegate {
    func databaseListener(capturedAccountBalanceUpdateEvent updatedBalance: String)
}
