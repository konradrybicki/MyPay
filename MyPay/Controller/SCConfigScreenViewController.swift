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
    
    // keyboard labels
    @IBOutlet weak var oneKeyLabel: UILabel!
    @IBOutlet weak var twoKeyLabel: UILabel!
    @IBOutlet weak var threeKeyLabel: UILabel!
    @IBOutlet weak var fourKeyLabel: UILabel!
    @IBOutlet weak var fiveKeyLabel: UILabel!
    @IBOutlet weak var sixKeyLabel: UILabel!
    @IBOutlet weak var sevenKeyLabel: UILabel!
    @IBOutlet weak var eightKeyLabel: UILabel!
    @IBOutlet weak var nineKeyLabel: UILabel!
    @IBOutlet weak var zeroKeyLabel: UILabel!
    @IBOutlet weak var backspaceKeyArrow: UIImageView!
    
    // keyboard buttons
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
    
    // counters
    var currentLoginAttempt: Int!
    var enteredDigits: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // text color switching problem (black/white) - this line makes sure the text won't dissapear from the screen
        currentLoginAttempt = 1
    }
    
    // navigation
    
    @IBAction func unwindButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // keyboard methods
    
    @IBAction func numericKeyPressed(_ sender: UIButton) {
        
        // vibration
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // action
        
        if enteredDigits == 0 {
            
            // digit entrance
            firstPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            enteredDigits += 1
            
            // backspace key unlock
            backspaceKeyArrow.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            backspaceKey.isUserInteractionEnabled = true
        }
        else if enteredDigits == 1 {
            secondPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            enteredDigits += 1
        }
        else if enteredDigits == 2 {
            thirdPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            enteredDigits += 1
        }
        else {
            // pin dot
            fourthPinDot.tintColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
            
            // keyboard lock
            lockKeyboard(true)
            
            // action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                if self.currentLoginAttempt == 1 {
                    
                    // communicate change
                    self.communicate.text = "Please repeat a security code for Your account"
                    
                    // pin dots reset
                    self.firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    self.fourthPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
                    
                    // backspace key arrow hide
                    self.backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                    // counters
                    self.currentLoginAttempt += 1
                    self.enteredDigits = 0
                    
                    // keyboard unlock (backspace key stays locked)
                    self.lockKeyboard(false)
                }
                else {
                    self.performSegue(withIdentifier: "presentRegistrationEndScreen", sender: self)
                }
            }
        }
    }
    
    func lockKeyboard(_ choice: Bool) -> Void {
        
        if choice == true {
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
        else {
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
    
    @IBAction func backspaceKeyPressed(_ sender: UIButton) {
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        if enteredDigits == 3 {
            thirdPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            enteredDigits -= 1
        }
        else if enteredDigits == 2 {
            secondPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            enteredDigits -= 1
        }
        else if enteredDigits == 1 {
            
            // digit deletion
            firstPinDot.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
            enteredDigits -= 1
            
            // backspace key lock
            backspaceKeyArrow.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            backspaceKey.isUserInteractionEnabled = false
        }
    }
}
