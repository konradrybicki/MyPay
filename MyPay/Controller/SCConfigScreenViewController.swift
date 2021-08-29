//
//  ViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 28/07/2021.
//

import UIKit

class SCConfigScreenViewController: UIViewController {
    
    // communicate
    @IBOutlet weak var communicate: UILabel!
    
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
    
    // user object
    public var user: User!
    
    // security code
    private var securityCode_firstAttempt = ""
    private var securityCode_secondAttempt = ""
    
    // counters
    var currentAttempt: Int!
    var enteredDigits: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // communicate text color switching bug "fix"
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // backspace key lock
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backspaceKey.isUserInteractionEnabled = false
        
        // counters
        currentAttempt = 1
        enteredDigits = 0
    }
    
    @IBAction func unwindButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // keyboard
    
    @IBAction func numericKeyPressed(_ sender: UIButton) {
        
        // digit entrance
        
        let newDigit: Int
        
        switch sender {
        
        case oneKey:
            newDigit = 1
        case twoKey:
            newDigit = 2
        case threeKey:
            newDigit = 3
        case fourKey:
            newDigit = 4
        case fiveKey:
            newDigit = 5
        case sixKey:
            newDigit = 6
        case sevenKey:
            newDigit = 7
        case eightKey:
            newDigit = 8
        case nineKey:
            newDigit = 9
        default:
            newDigit = 0
        }
        
        if currentAttempt == 1 {
            securityCode_firstAttempt += String(newDigit)
        }
        else {
            securityCode_secondAttempt += String(newDigit)
        }
        
        enteredDigits += 1
        
        // vibration
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        switch enteredDigits {
        
        case 1:
            
            // pin dot color change
            firstPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            
            // backspace key unlock
            unlockBackspace()
        case 2:
            secondPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        case 3:
            thirdPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        default:
            
            fourthPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            
            // keyboard lock
            lockKeyboard()
            
            // 0.25s delay, just to hold a pin dot color change, so that the user actually sees it changing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                if self.currentAttempt == 1 {
                    
                    // communicate change
                    self.communicate.text = "Please repeat a security code for Your account"
                    
                    // pin dots reset
                    self.firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.fourthPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    
                    // backspace key arrow hide
                    self.backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                    // counters values change
                    self.currentAttempt = 2
                    self.enteredDigits = 0
                    
                    // keyboard unlock (backspace key stays locked)
                    self.unlockKeyboard_withoutBackspace()
                }
                else if self.currentAttempt == 2 {
                    
                    // security code validation
                    let bothAttemptsMatch: Bool = self.securityCode_firstAttempt == self.securityCode_secondAttempt
                    
                    if bothAttemptsMatch == true {
                        
                        // loading animation
                        self.displayLoadingAnimation()
                        
                        // cryptography - salt generation
                        
                        let salt: String
                        
                        do {
                            salt = try CryptoService.generateSalt()
                        }
                        catch {
                            
                            // error communicate
                            
                            var errorCommunicate = ""
                            
                            if let _ = error as? DataGenerationError {
                                errorCommunicate = "Data generation error, please try again in a moment"
                            }
                            else if error as! DatabaseError == .connectionFailure {
                                errorCommunicate = "Database connection failure, please try again in a moment"
                            }
                            else if error as! DatabaseError == .interactionError {
                                errorCommunicate = "Database interaction error, please try again in a moment"
                            }
                            
                            // communicate screen
                            
                            let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
                            
                            self.present(communicateVC, animated: true) {
                                self.hideLoadingAnimation()
                            }
                            
                            return
                        }
                        
                        // cryptography - security code hashing
                        
                        let hash = CryptoService.hash(securityCode: self.securityCode_secondAttempt, saltingWith: salt)
                        
                        // user object - security code data supplementation
                        
                        self.user.securityCodeHash = hash
                        self.user.securityCodeSalt = salt
                        
                        // registration
                        
                        do {
                            try self.user.register()
                        }
                        catch {
                            
                            var errorCommunicate = ""
                            
                            if let databaseError = error as? DatabaseError {
                                
                                if databaseError == .connectionFailure {
                                    errorCommunicate = "Database connection failure, please try again in a moment"
                                }
                                else if databaseError == .dataSavingFailure {
                                    errorCommunicate = "Data saving failure, please try again in a moment"
                                }
                                else if databaseError == .interactionError {
                                    errorCommunicate = "Database interaction error, please try again in a moment"
                                }
                            }
                            else if error as! DataGenerationError == .def {
                                errorCommunicate = "Data generation error, please try again in a moment"
                            }
                            
                            let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: errorCommunicate)
                            
                            self.present(communicateVC, animated: true) {
                                self.hideLoadingAnimation()
                            }
                        }
                        
                        // registration complete
                        
                        let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: "Your MyPay account has been created, You can log in now 😊", andNewDestinationVC: "WelcomeScreenViewController")
                        
                        self.present(communicateVC, animated: true) {
                            self.hideLoadingAnimation()
                        }
                    }
                    else {
                        
                        // strong, longer vibration
                        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                        notificationFeedbackGenerator.notificationOccurred(.error)
                        
                        // error communicate
                        
                        let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: "Security code mismatch!\nPlease try again")
                        
                        self.present(communicateVC, animated: true) {
                            
                            // communicate change
                            self.communicate.text = "Please enter a security code for Your account"
                            
                            // pin dots reset
                            self.firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                            self.secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                            self.thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                            self.fourthPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                            
                            // backspace key arrow hide
                            self.backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            
                            // security code reset for both attempts
                            self.securityCode_firstAttempt = ""
                            self.securityCode_secondAttempt = ""
                            
                            // counters values change
                            self.currentAttempt = 1
                            self.enteredDigits = 0
                            
                            // keyboard unlock (backspace key stays locked)
                            self.unlockKeyboard_withoutBackspace()
                            
                            // loading animation hide
                            self.hideLoadingAnimation()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backspaceKeyPressed(_ sender: UIButton) {
        
        // counter decrementation
        enteredDigits -= 1
        
        // vibration
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()

        switch enteredDigits {
        
        case 2:
            
            // pin dot color change
            thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            
            // pin character "drop"
            if currentAttempt == 1 {
                securityCode_firstAttempt = String(securityCode_firstAttempt.prefix(2))
            }
            else {
                securityCode_secondAttempt = String(securityCode_secondAttempt.prefix(2))
            }
            
        case 1:
            
            secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            
            if currentAttempt == 1 {
                securityCode_firstAttempt = String(securityCode_firstAttempt.prefix(1))
            }
            else {
                securityCode_secondAttempt = String(securityCode_secondAttempt.prefix(1))
            }
            
        default:
            
            firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            
            // security code reinitialization
            if currentAttempt == 1 {
                securityCode_firstAttempt = ""
            }
            else {
                securityCode_secondAttempt = ""
            }
            
            // backspace key lock
            lockBackspace()
        }
    }
    
    func unlockBackspace() -> Void {
        backspaceKeyArrow.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backspaceKey.isUserInteractionEnabled = true
    }
    
    func lockBackspace() -> Void {
        backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backspaceKey.isUserInteractionEnabled = false
    }
    
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
}
