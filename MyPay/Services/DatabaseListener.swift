//
//  DatabaseListener.swift
//  MyPay
//
//  Created by Konrad Rybicki on 13/09/2021.
//

import Foundation
import UIKit
import MySQL

/// Listens for an account balance change database event and informs the delegate upon it. The main goal of that functionality is to provide realtime account balance updates, without using any external mechanisms

public class DatabaseListener: MySQLManager { // MySQLManager subclassing is dicted by a need of reusing the code, provided by establishConnection() and closeConnection() methods
    
    public static var delegate: DatabaseListenerDelegate!
    
    private static var shouldListen: Bool! // controlls listening loop
    
    public static var errorDisplayed = false // controlls error display (the error is meant to be displayed only once after the user has logged in)
    
    /// Moves to the background thread, connects to the database and launches an account balance selection loop, to capture an account balance change. In such case, moves back to the main thread, informs the delegate about the change and continues listening on the background thread
    
    public static func listenForAccountBalanceUpdates() -> Void {
        
        // launching code on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.shouldListen = true
            
            // client and database stored account balance
            var accountBalance_client = GlobalVariables.loggedUsersAccountBalance!
            var accountBalance_database: String = ""
            
            // logged user's id, needed for account balance selection
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
                            self.delegate.databaseListener(capturedAccountBalanceUpdate: accountBalance_database)
                        }
                        
                        // client balance variable update
                        accountBalance_client = accountBalance_database
                    }
                    
                    // interval between iterations (1 second)
                    sleep(1)
                }
                
                // database connection closing
                
                try self.closeConnection(connection)
            }
            catch {
                
                // error display (only once after user has logged in)
                
                if errorDisplayed == false {
                    
                    // error communicate preparation
                    
                    var errorCommunicate = ""
                    
                    if error as! DatabaseError == .connectionFailure {
                        errorCommunicate = "We're having problems with the connection\n\nYour account's balance might not refresh automatically"
                    }
                    else if error as! DatabaseError == .dataLoadingFailure {
                        errorCommunicate = "We're having problems\n\nYour account's balance might not refresh automatically"
                    }
                    
                    // main thread error display (UI interaction)
                    
                    DispatchQueue.main.async {
                        self.displayErrorFromTopController(errorCommunicate)
                    }
                    
                    self.errorDisplayed = true
                    
                }
                
                // listening relaunch attempt (the aim of below solution is to avoid method call reccurence)
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1)) {
                    self.listenForAccountBalanceUpdates()
                }
                
                return
            }
            
            // main thread delegation (listening finished)
            
            DispatchQueue.main.async {
                self.delegate.databaseListenerDidEndListening()
            }
        }
    }
    
    /// Stops a listening loop
    
    public static func stopListening() -> Void {
        shouldListen = false
    }
    
    /// Allows DatabaseListener to display the errors again
    
    public static func displayErrors() -> Void {
        if errorDisplayed == true {
           errorDisplayed = false
        }
    }
}

extension DatabaseListener {
    
    /// Selects specified user's account balance from the database, using existing database connection
    
    private static func selectAccountBalance(forUserWith loggedUsersId: Int16, usingConnection connection: MySQL.Connection) throws -> String {
        
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
    
    /// Identifies the top (last presented) view controller and uses it to display an error communicate
    
    private static func displayErrorFromTopController(_ errorCommunicate: String) {
        
        // top controller identification
        
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

public protocol DatabaseListenerDelegate {
    func databaseListener(capturedAccountBalanceUpdate updatedBalance: String)
    func databaseListenerDidEndListening()
}

// below solution is the workaround for declaring optional methods in protocols (methods that can, but not neccesarily have to be defined in classes, that implement the protocol)

extension DatabaseListenerDelegate {
    func databaseListener(capturedAccountBalanceUpdate updatedBalance: String) {}
    func databaseListenerDidEndListening() {}
}
