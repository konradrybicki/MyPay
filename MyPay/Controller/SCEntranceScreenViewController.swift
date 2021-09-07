//
//  SCEntranceScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

class SCEntranceScreenViewController: UIViewController {

    // pin dots
    @IBOutlet weak var firstPinDot: UIImageView!
    @IBOutlet weak var secondPinDot: UIImageView!
    @IBOutlet weak var thirdPinDot: UIImageView!
    @IBOutlet weak var fourthPinDot: UIImageView!
    
    // keyboard
    @IBOutlet weak var oneKey: UIButton!
    @IBOutlet weak var twoKey: UIButton!
    @IBOutlet weak var threeKey: UIButton!
    @IBOutlet weak var fourKey: UIButton!
    @IBOutlet weak var fiveKey: UIButton!
    @IBOutlet weak var sixKey: UIButton!
    @IBOutlet weak var sevenKey: UIButton!
    @IBOutlet weak var eightKey: UIButton!
    @IBOutlet weak var nineKey: UIButton!
    @IBOutlet weak var zeroKey: UIButton!
    @IBOutlet weak var backspaceKey: UIButton!
    @IBOutlet weak var backspaceKeyArrow: UIImageView!
    
    // logging user's id
    public var loggingUsersId: Int16!
    
    // logging user's security code data
    private var loggingUsersSCHash: String!
    private var loggingUsersSCSalt: String!
    
    // security code, typed by the user
    private var typedSecurityCode: String!
    private var enteredDigits: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // logging user's security code data load
        
        do {
            
            let loggingUsersSecurityCodeData = try MySQLManager.selectSecurityCodeData(forUserWith: loggingUsersId)
            
            loggingUsersSCHash = loggingUsersSecurityCodeData.hash
            loggingUsersSCSalt = loggingUsersSecurityCodeData.salt
        }
        catch {
            
            // error communicate preparation
            
            var errorCommunicate = ""
            
            if error as! DatabaseError == .connectionFailure {
                errorCommunicate = "Database connection failure, please try again in a moment"
            }
            else if error as! DatabaseError == .dataLoadingFailure {
                errorCommunicate = "Data loading failure, please try again in a moment"
            }
            
            // error communicate display
            
            let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
            
            self.present(communicateVC, animated: true) {
                
                // login form view controller loading animation hide (before the dismiss)
                
                let loginFormVC = self.presentingViewController as! LoginFormViewController
                loginFormVC.hideLoadingAnimation()
            }
            
            return
        }
        
        // backspace key lock
        
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backspaceKey.isUserInteractionEnabled = false
        
        // security code variables initialization
        
        typedSecurityCode = ""
        enteredDigits = 0
    }
    
    @IBAction func unwindArrowPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backspaceKeyPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentHomeScreen", sender: self)
    }
}
