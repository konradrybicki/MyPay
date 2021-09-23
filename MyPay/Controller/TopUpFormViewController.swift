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
        
        // amount text field set-up
        
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(<#T##@objc method#>), for: .editingChanged)
        
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
        
        let keyboardHeight = keyboardRectangle.height
        
        // "lifting" view creation
        
        let liftingView = UIView()
        
        let liftingView_heightConstraint = liftingView.heightAnchor.constraint(equalToConstant: keyboardHeight)
        
        NSLayoutConstraint.activate([liftingView_heightConstraint])
        
        // proceed button "lift-up"
        
        mainStackView.addSubview(liftingView)
    }
    
    // navigation
    
    @IBAction func unwindButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        
        // loading animation display
        displayLoadingAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            
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
            self.present(scEntranceScreenVC, animated: true) {
                self.hideLoadingAnimation()
            }
        }
    }
}
