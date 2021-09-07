//
//  LoginFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 03/09/2021.
//

import UIKit
import AudioToolbox // area code toolbar plus button press sound

/// Controlls the login form

class LoginFormViewController: UIViewController {

    // area code field
    @IBOutlet weak var areaCodeArea: UIView!
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaCodeLabel: UILabel!
    @IBOutlet weak var areaCodeTextFieldUnderline: UIView!
    var areaCodeToolbar: UIToolbar!
    
    // phone number field
    @IBOutlet weak var phoneNumberArea: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextFieldUnderline: UIView!
    var phoneNumberToolbar: UIToolbar!
    
    // proceed button
    @IBOutlet weak var proceedButton: UIButton!
    var proceedButtonLocked = true
    
    // field validation
    var areaCodeValid = true
    var phoneNumberValid = true
    
    // an id of the user, identified by the phone number (passed to the SCEntranceScreenViewController, upon view change)
    private var identifiedUsersId: Int16?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interface look (views rounding)
        
        areaCodeArea.layer.cornerRadius = 15
        areaCodeArea.clipsToBounds = true
        
        phoneNumberArea.layer.cornerRadius = 15
        phoneNumberArea.clipsToBounds = true
        
        proceedButton.layer.cornerRadius = 15
        proceedButton.clipsToBounds = true
        
        // text fields delegation
        
        areaCodeTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        // text fields text change event capture
        
        areaCodeTextField.addTarget(self, action: #selector(areaCodeTextFieldDidChangeEditing), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChangeEditing), for: .editingChanged)
        
        // toolbars
        
        areaCodeToolbar = createAreaCodeToolbar()
        areaCodeTextField.inputAccessoryView = areaCodeToolbar
        
        phoneNumberToolbar = createPhoneNumberToolbar()
        phoneNumberTextField.inputAccessoryView = phoneNumberToolbar
        
        // area code text field "activation", upon view entrance
        
        areaCodeTextField.becomeFirstResponder()
    }
    
    // navigation
    
    @IBAction func unwindArrowPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        // TODO: proceed button pressed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: prepare for segue
    }
}

//MARK: - Area code toolbar methods

extension LoginFormViewController {
    
    /// Creates an area code toolbar, consistent of two buttons: plus button on the left side, and done button on the right side
    
    func createAreaCodeToolbar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let plusButton = UIBarButtonItem(title: "+", style: UIBarButtonItem.Style.plain, target: nil, action: #selector(areaCodeToolbar_plusButtonPressed))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(areaCodeToolbar_doneButtonPressed))
        
        toolbar.setItems([plusButton, flexibleSpace, doneButton], animated: true)
        
        return toolbar
    }
    
    @objc func areaCodeToolbar_plusButtonPressed() {
        
        // plus character addition
        
        let areaCode = areaCodeTextField.text!
        
        if areaCode == "" {
            areaCodeTextField.text = "+"
            AudioServicesPlaySystemSound(1104)
        }
        else {
            let firstCharacter = Array(areaCode)[0]
            
            if firstCharacter != "+" {
                areaCodeTextField.text = "+" + areaCode
                AudioServicesPlaySystemSound(1104)
            }
        }
        
        // area code validation, through the areaCodeTextFieldDidChangeEditing() method (only if the '+' character was actually added to the area code)
        
        let areaCode_updated = areaCodeTextField.text!
        
        let plusCharacterAdded: Bool = areaCode != areaCode_updated
        
        if plusCharacterAdded == true {
            areaCodeTextFieldDidChangeEditing()
        }
    }
    
    @objc func areaCodeToolbar_doneButtonPressed() {
        
        // text field editing end
        areaCodeTextField.endEditing(true)
        
        // potential field switch
        
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        if areaCode != "" && areaCodeValid == true &&
            phoneNumber == "" {
            
            phoneNumberTextField.becomeFirstResponder()
        }
    }
}

//MARK: - Phone number toolbar methods

extension LoginFormViewController {
    
    /// Creates a phone number toolbar, consistent of one 'done' button on the right side
    
    func createPhoneNumberToolbar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(phoneNumberToolbar_doneButtonPressed))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        return toolbar
    }
    
    @objc func phoneNumberToolbar_doneButtonPressed() {
        phoneNumberTextField.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate

extension LoginFormViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // empty/valid fields blue mark
        
        if textField == areaCodeTextField && areaCodeValid == true {
            paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
        else if textField == phoneNumberTextField && phoneNumberValid == true {
            paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
    }
    
    /// Reacts to an 'area code' text field text change event
    
    @objc func areaCodeTextFieldDidChangeEditing() {
        
        let areaCode_updated = areaCodeTextField.text!
        
        if areaCode_updated != "" {
            
            let areaCode_updated_valid = ValidationService.isAreaCodeValid(areaCode_updated)
            
            if areaCodeValid == true && areaCode_updated_valid == false {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                
                areaCodeValid = false
            }
            else if areaCodeValid == false && areaCode_updated_valid == true {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                areaCodeValid = true
            }
        }
        else {
            
            if areaCodeValid == false {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                areaCodeValid = true
            }
        }
        
        return
    }
    
    /// Reacts to a 'phone number' text field text change event
    
    @objc func phoneNumberTextFieldDidChangeEditing() {
        
        let phoneNumber_updated = phoneNumberTextField.text!
        
        if phoneNumber_updated != "" {
            
            let phoneNumber_updated_valid = ValidationService.isPhoneNumberValid(phoneNumber_updated)
            
            if phoneNumberValid == true && phoneNumber_updated_valid == false {
                
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                
                phoneNumberValid = false
            }
            else if phoneNumberValid == false && phoneNumber_updated_valid == true {
                
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                phoneNumberValid = true
            }
        }
        else {
            
            if phoneNumberValid == false {
                
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                phoneNumberValid = true
            }
        }
        
        return
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // form field color change (and validation, in case of a birth date text field)
        
        if textField == areaCodeTextField {
            
            let areaCode = areaCodeTextField.text!
            
            if areaCode == "" {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else if areaCodeValid == true {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
        }
        else if textField == phoneNumberTextField {
            
            let phoneNumber = phoneNumberTextField.text!
            
            if phoneNumber == "" {
                
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else if phoneNumberValid == true {
                
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
        }
        
        // proceed button potential state change
        
        if proceedButtonLocked == true {
            
            // fields check for potential unlock
            
            if allFieldsValid() == true {
                
                unlockProceedButton()
                proceedButtonLocked = false
            }
        }
        else {
            
            // fields check for potential lock
            
            if atLeastOneFieldInvalidOrEmpty() == true {
                
                lockProceedButton()
                proceedButtonLocked = true
            }
        }
    }
}

//MARK: - Cell painting method

extension LoginFormViewController {
    
    /// Changes specified cell's label and underline colors to given ones
    
    func paintCell(for textField: UITextField!, with labelColor: UIColor, and underlineColor: UIColor) {
        
        if textField == areaCodeTextField {
            
            UIView.animate(withDuration: 0.2) {
                self.areaCodeLabel.textColor = labelColor
                self.areaCodeTextFieldUnderline.backgroundColor = underlineColor
            }
        }
        else if textField == phoneNumberTextField {
            
            UIView.animate(withDuration: 0.2) {
                self.phoneNumberLabel.textColor = labelColor
                self.phoneNumberTextFieldUnderline.backgroundColor = underlineColor
            }
        }
    }
}

//MARK: - Proceed button manipulation methods

extension LoginFormViewController {
    
    /// Checks whether all form fields are valid
    
    func allFieldsValid() -> Bool {
        
        // validness check
        
        let allFieldsValid = (
            areaCodeValid == true &&
            phoneNumberValid == true
        )
        
        if allFieldsValid == false {
            return false
        }
        
        // emptyness check (fields marked as valid could be empty, due to the 'true' default value)
        
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        let allFieldsFulfilled = (
            areaCode != "" &&
            phoneNumber != ""
        )
            
        // final result
        
        if allFieldsFulfilled == true && allFieldsValid == true {
            return true
        }
        else {
            return false
        }
    }

    /// Checks if at least one form field is either invalid or empty
    
    func atLeastOneFieldInvalidOrEmpty() -> Bool {
        
        let atLeastOneFieldInvalid = (
            areaCodeValid == false ||
            phoneNumberValid == false
        )
        
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        let atLeastOneFieldEmpty = (
            areaCode == "" ||
            phoneNumber == ""
        )
        
        if atLeastOneFieldInvalid == true || atLeastOneFieldEmpty == true {
            return true
        }
        else {
            return false
        }
    }

    /// Enables user interaction on the proceed button, changing its color simultaneously
    
    func unlockProceedButton() {
        proceedButton.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        proceedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        proceedButton.isUserInteractionEnabled = true
    }

    /// Disables user interaction on the proceed button, changing its color simultaneously
    
    func lockProceedButton() {
        proceedButton.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
        proceedButton.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        proceedButton.isUserInteractionEnabled = false
    }
}
