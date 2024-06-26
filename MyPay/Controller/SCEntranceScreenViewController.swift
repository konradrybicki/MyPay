//
//  SCEntranceScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit
import CryptoSwift

/// Controlls the Security Code entrance screen, displayed:
/// 1) After entering an identified phone number, in the login form
/// 2) Upon an account access lock
/// 3) Upon a top-up confirmation

class SCEntranceScreenViewController: UIViewController {
    
    // unwind button
    @IBOutlet weak var unwindButton: UIButton!
    @IBOutlet weak var unwindButtonArrow: UIImageView!
    
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
    
    // entered security code
    private var enteredSecurityCode: String!
    private var enteredDigits: Int!
    
    // the delegate
    public var delegate: SCEntranceScreenDelegate!
    
    // segue destination (home screen) vc instance, initialized before performing the segue to set-up the delegate for potential errors
    private var segueDestinationVC: HomeScreenViewController!
    
    // top-up amount (top-up confirmation scenario)
    public var topUpAmount: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // security code data load/read (depending on the scenario)
        
        let userLogged: Bool = GlobalVariables.loggedUsersId != nil
        
        if userLogged == false { // (login scenario)
            
            // logging user's security code data load
            
            do {
                
                let loggingUsersSecurityCodeData = try MySQLManager.selectSecurityCodeData(forUserWith: loggingUsersId)
                
                loggingUsersSCHash = loggingUsersSecurityCodeData.hash
                loggingUsersSCSalt = loggingUsersSecurityCodeData.salt
            }
            catch {
                
                // view loading cancellation
                dismiss(animated: false) {
                    
                    // error handling delegation
                    self.delegate.scEntranceScreen(viewLoadingDidAbortWith: error)
                }
            }
        }
        else { // (all other scenarios)
            
            // logged user's security code data read
            
            self.loggingUsersSCHash = GlobalVariables.loggedUsersSCHash
            self.loggingUsersSCSalt = GlobalVariables.loggedUsersSCSalt
        }
        
        // backspace key lock
        
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backspaceKey.isUserInteractionEnabled = false
        
        // security code variables initialization
        
        enteredSecurityCode = ""
        enteredDigits = 0
    }
    
    @IBAction func unwindArrowPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Keyboard keypress methods

extension SCEntranceScreenViewController {
    
    @IBAction func numericKeyPressed(_ sender: UIButton) {
        
        // digit entrance
        
        let pressedKey = sender
        let enteredDigit: Int = getDigit(correspondingTo: pressedKey)
        
        enteredSecurityCode += String(enteredDigit)
        enteredDigits += 1
        
        // vibration (light)
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // pin dot color change + additional (depending on the number of entered digits)
        
        if enteredDigits == 1 {
            firstPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            unlockBackspace()
        }
        else if enteredDigits == 2 {
            secondPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        }
        else if enteredDigits == 3 {
            thirdPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        }
        else {
            fourthPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            
            // keyboard lock
            lockKeyboard()
            
            // 0.25s delay, just for the user to see fourth pin dot changing its color, before the view changes / error communicate displays
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
                // entered security code validation
                
                let enteredSecurityCodeValid = self.isEnteredSecurityCodeValid()
                
                if enteredSecurityCodeValid == true {
                    
                    if self.presentingViewController as? LoginFormViewController != nil { // (login scenario)
                        
                        // loading animation display
                        self.displayLoadingAnimation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                            
                            // logging user's data save (id, security code data)
                            GlobalVariables.loggedUsersId = self.loggingUsersId
                            GlobalVariables.loggedUsersSCHash = self.loggingUsersSCHash
                            GlobalVariables.loggedUsersSCSalt = self.loggingUsersSCSalt
                            
                            // forward view change (home screen)
                            self.performSegue(withIdentifier: "presentHomeScreen", sender: self)
                            
                            // loading animation hide
                            self.hideLoadingAnimation()
                        }
                    }
                    else if self.presentingViewController as? TopUpFormViewController != nil && self.topUpAmount != nil { // (top-up confirmation scenario)
                        
                        // loading animation display
                        self.displayLoadingAnimation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                        
                            // top-up data gathering
                            let accountNumber = GlobalVariables.loggedUsersAccountNumber!
                            let amount = self.topUpAmount
                            
                            // top-up instance creation
                            let confirmedTopUp = TopUp(target: accountNumber, amount!)
                            
                            do {
                                // top-up registration attempt
                                try confirmedTopUp.register()
                            }
                            catch {
                                
                                // error communicate vc preparation
                                
                                var errorCommunicate = ""
                                
                                if error as! DatabaseError == .connectionFailure {
                                    errorCommunicate = "Database connection failure, please try again in a moment"
                                }
                                else if error as! DatabaseError == .dataSavingFailure {
                                    errorCommunicate = "Data saving failure, please try again in a moment"
                                }
                                else if error as! DatabaseError == .dataUpdateFailure {
                                    errorCommunicate = "Data update failure, please try again in a moment"
                                }
                                
                                let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
                                
                                // top up related controllers instantiation
                                let scEntranceScreenVC = self
                                let topUpFormVC = self.presentingViewController as! TopUpFormViewController
                                
                                // sc entrance screen dismiss, top up form communicate display
                                scEntranceScreenVC.dismiss(animated: false) {
                                    topUpFormVC.present(communicateVC, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            // top-up registered successfully
                            
                            // (success communicate vc preparation)
                            let successCommunicate = "We're processing Your transaction ⏱"
                            let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: successCommunicate)
                            
                            // (all top-up related controllers instiantiation, including the home screen)
                            let scEntranceScreenVC = self
                            let topUpFormVC = self.presentingViewController as! TopUpFormViewController
                            let homeScreenVC = topUpFormVC.presentingViewController as! HomeScreenViewController
                            
                            // (top-up related controllers dismiss, home screen communicate presentation)
                            scEntranceScreenVC.dismiss(animated: false) {
                                topUpFormVC.dismiss(animated: false) {
                                    homeScreenVC.present(communicateVC, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    else { // account access unlock scenario
                        AccountAccessManager.unlockAccess(dismissing: self)
                    }
                }
                else {
                    
                    // vibration (error)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    
                    // appropriate communicate display
                    
                    let errorCommunicate = "Security code invalid\nPlease try again"
                    
                    let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
                    
                    self.present(communicateVC, animated: true) {
                        self.resetSecurityCodeEntranceAttempt()
                    }
                }
            }
        }
    }
    
    @IBAction func backspaceKeyPressed(_ sender: UIButton) {
        
        // digit deletion
        
        enteredSecurityCode = enteredSecurityCode.droppedLastCharacter()
        enteredDigits -= 1
        
        // vibration (light)
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // pin dot color change and backspace lock
        
        if enteredDigits == 2 {
            thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        }
        else if enteredDigits == 1 {
            secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        }
        else {
            firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            lockBackspace()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // segue destination (home screen) vc instantiation and delegate setup
        
        segueDestinationVC = segue.destination as? HomeScreenViewController
        segueDestinationVC.delegate = self
    }
}

//MARK: - Keyboard key digit extract method

extension SCEntranceScreenViewController {
    
    /// Returns an integer value, corresponding to a given numeric key (ex.: getDigit(correspondingTo: sevenKey) will return '7')
    
    func getDigit(correspondingTo numericKey: UIButton) -> Int {
        
        let correspondingDigit: Int
        
        switch numericKey {
        
        case oneKey:
            correspondingDigit = 1
        case twoKey:
            correspondingDigit = 2
        case threeKey:
            correspondingDigit = 3
        case fourKey:
            correspondingDigit = 4
        case fiveKey:
            correspondingDigit = 5
        case sixKey:
            correspondingDigit = 6
        case sevenKey:
            correspondingDigit = 7
        case eightKey:
            correspondingDigit = 8
        case nineKey:
            correspondingDigit = 9
        default:
            correspondingDigit = 0
        }
        
        return correspondingDigit
    }
}

//MARK: - Entered security code validation method

extension SCEntranceScreenViewController {
    
    /// Concatenates logging user's salt with entered security code, hashes the result and checks, whether its equal to a logging user's security code hash
    
    func isEnteredSecurityCodeValid() -> Bool {
        
        let enteredSecurityCode_salted = loggingUsersSCSalt + enteredSecurityCode
        let enteringUsersSCHash = enteredSecurityCode_salted.sha256()
        
        if enteringUsersSCHash == loggingUsersSCHash {
            return true
        }
        else {
            return false
        }
    }
}

//MARK: - View controller reset method

extension SCEntranceScreenViewController {
    
    /// Brings the view controller back to its initial state
    
    func resetSecurityCodeEntranceAttempt() -> Void {
        
        // pin dots reset
        firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        fourthPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        
        // backspace key arrow hide
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // entered security code reset
        enteredSecurityCode = ""
        enteredDigits = 0
        
        // keyboard unlock (backspace key stays locked)
        unlockKeyboard_withoutBackspace()
    }
}

//MARK: - Keyboard lock control methods

extension SCEntranceScreenViewController {
    
    /// Disables user interaction on all keyboard keys
    
    func lockKeyboard() -> Void {
        oneKey.isUserInteractionEnabled = false
        twoKey.isUserInteractionEnabled = false
        threeKey.isUserInteractionEnabled = false
        fourKey.isUserInteractionEnabled = false
        fiveKey.isUserInteractionEnabled = false
        sixKey.isUserInteractionEnabled = false
        sevenKey.isUserInteractionEnabled = false
        eightKey.isUserInteractionEnabled = false
        nineKey.isUserInteractionEnabled = false
        zeroKey.isUserInteractionEnabled = false
        backspaceKey.isUserInteractionEnabled = false
    }
    
    /// Enables user interaction on all keyboard keys, except the backspace
    
    func unlockKeyboard_withoutBackspace() -> Void {
        oneKey.isUserInteractionEnabled = true
        twoKey.isUserInteractionEnabled = true
        threeKey.isUserInteractionEnabled = true
        fourKey.isUserInteractionEnabled = true
        fiveKey.isUserInteractionEnabled = true
        sixKey.isUserInteractionEnabled = true
        sevenKey.isUserInteractionEnabled = true
        eightKey.isUserInteractionEnabled = true
        nineKey.isUserInteractionEnabled = true
        zeroKey.isUserInteractionEnabled = true
    }
    
    /// Makes the backspace key visible and enables user interaction on it
    
    func unlockBackspace() -> Void {
        backspaceKeyArrow.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backspaceKey.isUserInteractionEnabled = true
    }
    
    /// Hides the backspace key and disables user interaction on it
    
    func lockBackspace() -> Void {
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backspaceKey.isUserInteractionEnabled = false
    }
}

//MARK: - HomeScreenDelegate

extension SCEntranceScreenViewController: HomeScreenDelegate {
    
    func homeScreen(viewLoadingDidAbortWith error: Error) {
        
        // logged user's id "deletion"
        
        GlobalVariables.loggedUsersId = nil
        
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
        
        present(communicateVC, animated: true) {
            self.resetSecurityCodeEntranceAttempt()
            self.hideLoadingAnimation()
        }
    }
}

//MARK: - Delegate protocol

public protocol SCEntranceScreenDelegate {
    func scEntranceScreen(viewLoadingDidAbortWith error: Error)
}
