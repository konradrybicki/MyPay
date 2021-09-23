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
    var isAmountValid = true
    
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
        
        // amount text field configuration
        /*
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(<#T##@objc method#>), for: .editingChanged)
        */
        // users account balance display
        
        balance.text = GlobalVariables.loggedUsersAccountBalance!
        
        // "keyboard will show" notification capture, needed to get keyboard height, before lifting the proceed button up above it
        
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
        let keyboardHeight = keyboardRectangle.height
        
        // "lifting" view creation
        
        let liftingView = UIView()
        
        let liftingView_heightConstraint = liftingView.heightAnchor.constraint(equalToConstant: keyboardHeight)
        
        NSLayoutConstraint.activate([liftingView_heightConstraint])
        
        // proceed button "lift-up"
        
        mainStackView.addSubview(liftingView)
    }
}
