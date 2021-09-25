//
//  TopUpFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 20/09/2021.
//

import UIKit

/// Controlls top up form

class TopUpFormViewController: UIViewController {
    
    // the amount field
    @IBOutlet weak var amountPreciseArea: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextFieldUnderline: UIView!
    var amountValid = true
    
    // Amount text field's editing control variable (set to 'false' by default, changed to 'true' while dismissing the view).
    // The property was implemented as a keyboard-related bug fix, to prevent the keyboard from remaining displayed after
    // dismissing the view.
    var amountTextFieldShouldEndEditing = false
    
    // user's account balance
    @IBOutlet weak var balance: UILabel!
    
    // proceed button
    @IBOutlet weak var proceedButton: UIButton!
    var proceedButtonLocked = true
    
    // main stack view, needed to lift up the proceed button above the keyboard
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interface elements rounding
        
        amountPreciseArea.layer.cornerRadius = 15
        amountPreciseArea.clipsToBounds = true
        
        proceedButton.layer.cornerRadius = 15
        proceedButton.clipsToBounds = true
        
        // amount text field set-up
        
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChangeEditing), for: .editingChanged)
        
        // users account balance display
        
        balance.text = GlobalVariables.loggedUsersAccountBalance!
        
        // proceed button "lift-up", right after the 'keyboardWillShow' notification capture (before we "lift" the proceed button up above the keyboard, we need to know its height to set-up the distance between the proceed button container and the bottom side of the screen)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(liftProceedButtonAboveTheKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        // amount text field "activation"
        
        amountTextField.becomeFirstResponder()
    }
    
    @objc func liftProceedButtonAboveTheKeyboard(_ keyboardWillShowNotification: Notification) {
        
        // keyboard height establishment
        
        let keyboardFrame: NSValue = keyboardWillShowNotification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        var keyboardHeight = keyboardRectangle.height
        
        // keyboard height modification (bottom padding height cutoff)
        
        let window = UIApplication.shared.keyWindow!
        let bottomPaddingHeight = window.safeAreaInsets.bottom
        
        keyboardHeight -= bottomPaddingHeight
        
        // "lifting" view creation
        
        let liftingView = UIView()
        
        let liftingView_heightConstraint = liftingView.heightAnchor.constraint(equalToConstant: keyboardHeight)
        
        NSLayoutConstraint.activate([liftingView_heightConstraint])
        
        // proceed button "lift-up"
        
        mainStackView.addArrangedSubview(liftingView)
        
        // observer removal (so that the proceed button is lifted only once per loaded view)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    // navigation
    
    @IBAction func unwindButtonPressed(_ sender: UIButton) {
        amountTextFieldShouldEndEditing = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        
        // SC entrance screen vc instantiation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scEntranceScreenVC = storyboard.instantiateViewController(withIdentifier: "SCEntranceScreenViewController") as! SCEntranceScreenViewController
        
        // passed top-up amount preparation
        let passedTopUpAmount_str = self.amountTextField.text!
        let passedTopUpAmount_dbl = Double(passedTopUpAmount_str)
        
        // SC entrance screen vc setup
        scEntranceScreenVC.modalTransitionStyle = .coverVertical
        scEntranceScreenVC.modalPresentationStyle = .fullScreen
        scEntranceScreenVC.topUpAmount = passedTopUpAmount_dbl
        
        // SC entrance screen vc presentation
        self.present(scEntranceScreenVC, animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension TopUpFormViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // amount field blue mark
        paintAmountCell(with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
    }
    
    /// Reacts to an amountTextField's text change event
    
    @objc func amountTextFieldDidChangeEditing() {
        
        // potential amount field/validness state change
        
        let amount_updated = amountTextField.text!
        
        if amount_updated != "" {
            
            // validation
            let amount_updated_valid = ValidationService.isTopUpAmountValid(Double(amount_updated)!)
            
            // result (became invalid)
            if amountValid == true && amount_updated_valid == false {
                
                paintAmountCell(with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                amountValid = false
            }
            // result (became valid)
            else if amountValid == false && amount_updated_valid == true {
                
                paintAmountCell(with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                amountValid = true
            }
        }
        else {
            
            // invalid became empty
            if amountValid == false {
                
                paintAmountCell(with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                amountValid = true
            }
        }
        
        // proceed button potential state change
        
        if proceedButtonLocked == true {
            
            // checking for potential unlock
            
            if amountFieldFullfilledAndValid() == true {
                
                unlockProceedButton()
                proceedButtonLocked = false
            }
        }
        else {
            
            // checking for potential lock
            
            if amountFieldInvalidOrEmpty() == true {
                
                lockProceedButton()
                proceedButtonLocked = true
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return amountTextFieldShouldEndEditing // 'false' by default, 'true' while dismissing the view
    }
}

//MARK: - Cell painting method

extension TopUpFormViewController {
    
    /// Changes the amount cell's label and underline colors to given ones
    
    func paintAmountCell(with labelColor: UIColor, and underlineColor: UIColor) {
        
        UIView.animate(withDuration: 0.2) {
            self.amountLabel.textColor = labelColor
            self.amountTextFieldUnderline.backgroundColor = underlineColor
        }
    }
}

//MARK: - Proceed button manipulation methods

extension TopUpFormViewController {
    
    /// Checks whether the amount field is both fulfilled and valid
    
    func amountFieldFullfilledAndValid() -> Bool {
        
        let amountFieldFulfilled: Bool = (amountTextField.text! != "")
        let amountFieldValid = (amountValid == true)
        
        if amountFieldFulfilled && amountFieldValid {
            return true
        }
        else {
            return false
        }
    }
    
    /// Checks whether the amount field is either invalid or empty
    
    func amountFieldInvalidOrEmpty() -> Bool {
        
        let amountFieldInvalid: Bool = (amountValid == false)
        let amountFieldEmpty: Bool = (amountTextField.text! == "")
        
        if amountFieldInvalid || amountFieldEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    /// Enables user interaction on the proceed button, changing its color simultaneously
    
    func unlockProceedButton() {
        proceedButton.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        proceedButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        proceedButton.isUserInteractionEnabled = true
    }

    /// Disables user interaction on the proceed button, changing its color simultaneously
    
    func lockProceedButton() {
        proceedButton.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
        proceedButton.setTitleColor(#colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1), for: .normal)
        proceedButton.isUserInteractionEnabled = false
    }
}
