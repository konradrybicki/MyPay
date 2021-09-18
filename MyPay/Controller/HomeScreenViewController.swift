//
//  HomeScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit
import AudioToolbox

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var account: UIView!
    @IBOutlet weak var topUpButton: UIButton!
    
    @IBOutlet weak var balance_integerPart: UILabel!
    @IBOutlet weak var balance_decimalPart: UILabel!
    
    public var delegate: HomeScreenDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // view and button rounding
        
        appLogo.layer.cornerRadius = 7
        appLogo.clipsToBounds = true
        
        account.layer.cornerRadius = 15
        account.clipsToBounds = true
        
        topUpButton.layer.cornerRadius = 10
        topUpButton.clipsToBounds = true
        
        // logged user's account balance load and display
        
        loadLoggedUsersAccountBalance()
        displayLoggedUsersAccountBalance()
        
        // database listening initialization, for realtime account balance updates
        
        DatabaseListener.delegate = self
        DatabaseListener.listenForAccountBalanceUpdates()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentLogoutScreen", sender: self)
    }
    
    /// Uses MySQLManager's selectAccountBalance() method to select logged user's account balance from the database. After the balance has been selected, saves it in a global variable. In case of an error, aborts view loading and informs the delegate about the circumstances
    
    func loadLoggedUsersAccountBalance() -> Void {
        
        // logged user's account balance database selection
        
        let loggedUsersId = GlobalVariables.loggedUsersId!
        
        let loggedUsersAccountBalance: String
        
        do {
            loggedUsersAccountBalance = try MySQLManager.selectAccountBalance(forUserWithId: loggedUsersId)
        }
        catch {
            
            // view loading cancellation
            dismiss(animated: false) {
                
                // error handling delegation
                self.delegate.homeScreen(viewLoadingDidAbortWith: error)
            }
            
            return
        }
        
        // selected balance "save" (global variable)
        
        GlobalVariables.loggedUsersAccountBalance = loggedUsersAccountBalance
    }
    
    /// Prepares logged user's account balance to display, dividing it into integer and decimal parts, according to the interface structure. After the balance has been prepared, assigns both values to responding labels 'text' properties
    
    func displayLoggedUsersAccountBalance() -> Void {
        
        // balance display preparation
        
        let loggedUsersBalance: String = GlobalVariables.loggedUsersAccountBalance!
        
        // (integer part)
        
        let balance_integerPart: String
        
        var begIndex = loggedUsersBalance.startIndex
        let dotIndex = loggedUsersBalance.firstIndex(of: ".")
        var endIndex = loggedUsersBalance.index(dotIndex!, offsetBy: -1)
        
        balance_integerPart = String(loggedUsersBalance[begIndex...endIndex])
        
        // (decimal part)
        
        var balance_decimalPart: String
        
        begIndex = loggedUsersBalance.index(dotIndex!, offsetBy: 1)
        endIndex = loggedUsersBalance.index(loggedUsersBalance.endIndex, offsetBy: -1)
        
        balance_decimalPart = String(loggedUsersBalance[begIndex...endIndex])
        
        if balance_decimalPart.count == 1 {
            balance_decimalPart += "0"
        }
        
        // display-ready balance display
        
        self.balance_integerPart.text = balance_integerPart
        self.balance_decimalPart.text = "." + balance_decimalPart
    }
}

extension HomeScreenViewController: DatabaseListenerDelegate {
    
    func databaseListener(capturedAccountBalanceUpdate updatedBalance: String) {
        
        // vibration
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        
        // balance update
        GlobalVariables.loggedUsersAccountBalance = updatedBalance
        
        // updated balance display
        displayLoggedUsersAccountBalance()
    }
}

public protocol HomeScreenDelegate {
    func homeScreen(viewLoadingDidAbortWith error: Error) -> Void
}
