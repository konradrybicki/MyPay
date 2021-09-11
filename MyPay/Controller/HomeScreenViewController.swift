//
//  HomeScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

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
        
        // logged user's account balance load (login and account access unlock scenarios only)
        
        let loginScenario: Bool = presentingViewController == nil // (segue perform)
        let accountAccessUnlockScenario: Bool = presentingViewController as? SCEntranceScreenViewController != nil
            
        if loginScenario || accountAccessUnlockScenario {
            loadLoggedUsersAccountBalance()
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentLogoutScreen", sender: self)
    }
    
    /// Loads and displays currently logged user's account balance. In case of an error, aborts view loading and informs the delegate about the circumstances
    
    func loadLoggedUsersAccountBalance() -> Void {
        
        // balance load
        
        let loggedUsersId = GlobalVariables.currentlyLoggedUsersId!
        
        let loggedUsersAccountBalance: String
        
        do {
            loggedUsersAccountBalance = try MySQLManager.selectAccountBalance(forUserWithId: loggedUsersId)
        }
        catch {
            
            // view loading cancellation
            dismiss(animated: false) {
                
                // presenting vc error handling (delegation)
                self.delegate.homeScreen(viewLoadingDidAbortWith: error)
            }
            
            return
        }
        
        // loaded balance display preparation   100.25
        
        // (integer part)
        
        let balance_integerPart: String
        
        var begIndex = loggedUsersAccountBalance.startIndex
        let dotIndex = loggedUsersAccountBalance.firstIndex(of: ".")
        var endIndex = loggedUsersAccountBalance.index(dotIndex!, offsetBy: -1)
        
        balance_integerPart = String(loggedUsersAccountBalance[begIndex...endIndex])
        
        // (decimal part)
        
        var balance_decimalPart: String
        
        begIndex = loggedUsersAccountBalance.index(dotIndex!, offsetBy: 1)
        endIndex = loggedUsersAccountBalance.index(loggedUsersAccountBalance.endIndex, offsetBy: -1)
        
        balance_decimalPart = String(loggedUsersAccountBalance[begIndex...endIndex])
        
        if balance_decimalPart.count == 1 {
            balance_decimalPart += "0"
        }
        
        // display-ready balance display
        
        self.balance_integerPart.text = balance_integerPart
        self.balance_decimalPart.text = "." + balance_decimalPart
    }
}

public protocol HomeScreenDelegate {
    func homeScreen(viewLoadingDidAbortWith error: Error) -> Void
}
