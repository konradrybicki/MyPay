//
//  AccountAccessManager.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/09/2021.
//

import UIKit

/// Controlls account access, while the user is logged in

public class AccountAccessManager {
    
    public static var accountAccessState: AccountAccessState = .unlocked
    
    /// Locks account access by displaying the SC entrance screen, as the last presented view controller (on the top of the chierarchy)
    
    public static func lockAccess() {
        
        // account balance updates listening stop
        
        DatabaseListener.stopListening()
        
        // top view controller identification
        
        var currentVC: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        
        while let presentedVC = currentVC.presentedViewController {
            currentVC = presentedVC
        }
        
        // (just for clarity)
        let topVC = currentVC
        
        // SC entrance screen vc instantiation
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scEntranceScreenVC = storyboard.instantiateViewController(withIdentifier: "SCEntranceScreenViewController") as! SCEntranceScreenViewController
        
        scEntranceScreenVC.loggingUsersId = GlobalVariables.loggedUsersId
        
        // SC entrance screen vc presentation
        
        scEntranceScreenVC.modalTransitionStyle = .crossDissolve
        scEntranceScreenVC.modalPresentationStyle = .fullScreen
        
        topVC.present(scEntranceScreenVC, animated: true) {
            
            // unwind arrow hide/lock
            scEntranceScreenVC.unwindButtonArrow.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            scEntranceScreenVC.unwindButton.isUserInteractionEnabled = false
            
            // account access state change
            self.accountAccessState = .locked
        }
    }
    
    /// Unlocks account access by dismissing the SC entrance screen, displayed upon the lockAccess() method call
    
    public static func unlockAccess() {
        
        // SC entrance screen (top) vc identification
        
        var currentVC = UIApplication.shared.keyWindow!.rootViewController!
        
        while let presentedVC = currentVC.presentedViewController {
            currentVC = presentedVC
        }
        
        let scEntranceScreenVC = currentVC
        
        // SC entrance screen dismiss (back to the presenting view)
        
        scEntranceScreenVC.modalTransitionStyle = .crossDissolve
        
        scEntranceScreenVC.dismiss(animated: true) {
            
            // account access state change
            self.accountAccessState = .unlocked
            
            // account balance updates listening reinitialization
            DatabaseListener.listenForAccountBalanceUpdates()
        }
    }
}

/// Defines the state that the account is currently in, in terms of access

public enum AccountAccessState {
    case unlocked
    case locked
}
