//
//  DatabaseListener.swift
//  MyPay
//
//  Created by Konrad Rybicki on 13/09/2021.
//

import Foundation
import UIKit

/// Listens for database events, such as an account balance update and informs the delegate upon them

public class DatabaseListener {
    
    public static var delegate: DatabaseListenerDelegate!
    
    private static var isListeningFor_accountBalanceUpdate: Bool!
    
    /// Launches an infinite while loop on the background thread, that uses the MySQLManager's selectAccountBalance() method to check for potential balance updates. In case of capturing an update, moves back to a main thread to inform the delegate
    
    public static func listenFor_loggedUsersAccountBalanceUpdate() -> Void {
        
        isListeningFor_accountBalanceUpdate = true
        
        // launching code on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            // client and database stored account balance
            var accountBalance_client = GlobalVariables.currentlyLoggedUsersAccountBalance!
            var accountBalance_database: String = ""
            
            // logged user's id, needed for account balance selection
            let loggedUsersId = GlobalVariables.currentlyLoggedUsersId!
            
            // connection error "locker", the error is meant to be displayed only once
            var connectionErrorDisplayed = false
            
            // account balance update check loop
            
            repeat {
                
                // balance selection
                
                do {
                    accountBalance_database = try MySQLManager.selectAccountBalance(forUserWithId: loggedUsersId)
                }
                catch {
                    
                    if error as! DatabaseError == .connectionFailure {
                        
                        if connectionErrorDisplayed == false {
                            
                            DispatchQueue.main.async {
                                handleErrorFromAnyController(error)
                            }
                            
                            connectionErrorDisplayed = true
                            
                            sleep(4)
                            continue
                        }
                    }
                    else if error as! DatabaseError == .dataLoadingFailure {
                        
                        DispatchQueue.main.async {
                            handleErrorFromAnyController(error)
                        }
                        
                        isListeningFor_accountBalanceUpdate = false
                        return
                    }
                }
                
                // balance comparison
                
                if accountBalance_database != accountBalance_client {
                    
                    DispatchQueue.main.async {
                        self.delegate.databaseListener(noticedLoggedUsersAccountBalanceUpdate: accountBalance_database)
                    }
                    
                    accountBalance_client = accountBalance_database
                }
                
                sleep(4)
                
            } while isListeningFor_accountBalanceUpdate == true
        }
    }
    
    public static func stopListeningFor_loggedUsersAccountBalanceUpdate() -> Void {
        isListeningFor_accountBalanceUpdate = false
    }
    
    
    private static func handleErrorFromAnyController(_ error: Error) {
        
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
    func databaseListener(noticedLoggedUsersAccountBalanceUpdate updatedBalance: String)
}
