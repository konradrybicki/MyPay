//
//  RegistrationFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 19/07/2021.
//

import Foundation
import UIKit
import AudioToolbox // area code toolbar plus button press sound

/// Controlls registration form

class RegistrationFormViewController: UIViewController {
    
    // form fields and input
    
    @IBOutlet weak var firstNameArea: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextFieldUnderline: UIView!
    
    @IBOutlet weak var lastNameArea: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextFieldUnderline: UIView!
    
    @IBOutlet weak var birthDateArea: UIView!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthDateTextFieldUnderline: UIView!
    var birthDateToolbar: UIToolbar!
    var birthDateDatePicker: UIDatePicker!
    
    @IBOutlet weak var areaCodeArea: UIView!
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaCodeLabel: UILabel!
    @IBOutlet weak var areaCodeTextFieldUnderline: UIView!
    var areaCodeToolbar: UIToolbar!
    
    @IBOutlet weak var phoneNumberArea: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextFieldUnderline: UIView!
    var phoneNumberToolbar: UIToolbar!
    
    // fields validation
    
    var firstNameValid: Bool = true
    var lastNameValid: Bool = true
    var birthDateValid: Bool = true
    var areaCodeValid: Bool = true
    var phoneNumberValid: Bool = true
    
    // proceed button
    
    @IBOutlet weak var proceedButtonArea: UIView!
    @IBOutlet weak var proceedButtonLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    var proceedButtonLocked = true
    
    // user object, that transfers "encapsulated" user data to the next view controller
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // form fields rounding (as well as the proceed button)
        
        firstNameArea.layer.cornerRadius = 15
        lastNameArea.layer.cornerRadius = 15
        birthDateArea.layer.cornerRadius = 15
        areaCodeArea.layer.cornerRadius = 15
        phoneNumberArea.layer.cornerRadius = 15
        proceedButtonArea.layer.cornerRadius = 15
        
        // text field delegation
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        birthDateTextField.delegate = self
        areaCodeTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        // "typeable" text fields text change event capture
        
        firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidChangeEditing), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidChangeEditing), for: .editingChanged)
        areaCodeTextField.addTarget(self, action: #selector(areaCodeTextFieldDidChangeEditing), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChangeEditing), for: .editingChanged)
        
        // birth date date picker
        
        birthDateDatePicker = createBirthDateDatePicker()
        birthDateTextField.inputView = birthDateDatePicker
        
        // birth date, area code and phone number toolbars
        
        birthDateToolbar = createBirthDateToolbar()
        birthDateTextField.inputAccessoryView = birthDateToolbar
        
        areaCodeToolbar = createAreaCodeToolbar()
        areaCodeTextField.inputAccessoryView = areaCodeToolbar
        
        phoneNumberToolbar = createPhoneNumberToolbar()
        phoneNumberTextField.inputAccessoryView = phoneNumberToolbar
        
        // first name text field "activation"
        
        firstNameTextField.becomeFirstResponder()
    }
    
    // navigation methods
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        // backward view change
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        
        // loading animation display
        displayLoadingAnimation()
        
        // (time for the loading animation to load up)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
        
            // last validation step - area code and phone number combination ("telephone number") database uniqueness check (for an active account)
            
            let areaCode = self.areaCodeTextField.text!
            let phoneNumber = self.phoneNumberTextField.text!
            
            let isNumberUnique: Bool
            
            do {
                isNumberUnique = try MySQLManager.isTelephoneNumberUniqueForAnActiveAccount(areaCode, phoneNumber)
            }
            catch {
                
                if error as! DatabaseError == .connectionFailure {
                    
                    // communicate screen vc instantiation
                    let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: "Database connection failed, please try again in a moment")
                    
                    // communicate screen vc presentation
                    self.present(communicateVC, animated: true) {
                        
                        // (completion)
                        
                        self.hideLoadingAnimation()
                    }
                }
                
                if error as! DatabaseError == .interactionError {
                    
                    let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: "Database interaction error, please try again in a moment")
                    
                    self.present(communicateVC, animated: true) {
                        self.hideLoadingAnimation()
                    }
                }
                
                return
            }
            
            // result
            
            if isNumberUnique == true {
                
                // validation complete - user object construction (data "encapsulation")
                
                let firstName = self.firstNameTextField.text!
                let lastName = self.lastNameTextField.text!
                let birthDate = self.birthDateTextField.text!
                let areaCode = self.areaCodeTextField.text!
                let phoneNumber = self.phoneNumberTextField.text!
                
                self.user = User(firstName, lastName, birthDate, areaCode, phoneNumber)
                            
                // forward view change, preceded with user object transfer
                self.performSegue(withIdentifier: "presentSCConfigScreen", sender: self)
                self.hideLoadingAnimation()
            }
            else {
                
                let communicateVC = CommunicateScreenViewController.instantiateVC(withCommunicate: "An account with given area code and phone number aready exists, please change the data and try again")
                
                self.present(communicateVC, animated: true) {
                    self.hideLoadingAnimation()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // user object transfer
        
        let scConfigScreenVC = segue.destination as! SCConfigScreenViewController
        scConfigScreenVC.user = self.user
    }
    
//MARK: - Birth date date picker and toolbar methods
    
    /// Creates an old-fashioned, wheel-styled date picker, for the birth date form field
    
    func createBirthDateDatePicker() -> UIDatePicker {
        
        let datePicker = UIDatePicker()
        
        // style
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        // date format
        datePicker.datePickerMode = .date
        
        // default date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        if let defaultDate = dateFormatter.date(from: "2000-01-01") {
            datePicker.date = defaultDate
        }
        else { // (the date will be set to current date)
            
            print("Error inside RegistrationFormViewController->createBirthDateDatePicker() - unexpected unwrap failure for 'dateFormatter.date' property ")
        }
        
        return datePicker
    }
    
    /// Creates a birth date toolbar, consistent of two buttons: cancel button on the left side and done button on the right side
    
    func createBirthDateToolbar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(birthDateToolbar_cancelButtonPressed))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(birthDateToolbar_doneButtonPressed))
        
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        
        return toolbar
    }
    
    @objc func birthDateToolbar_cancelButtonPressed() {
        birthDateTextField.endEditing(true)
    }

    @objc func birthDateToolbar_doneButtonPressed() {
        
        // date formatting (MySQL format)
        
        let birthDate = birthDateDatePicker.date
        var birthDate_formatted: String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        birthDate_formatted = dateFormatter.string(from: birthDate)
        birthDate_formatted = String(birthDate_formatted.prefix(10))
    
        // date assignment
        birthDateTextField.text = birthDate_formatted
        
        // text field editing end
        birthDateTextField.endEditing(true)
        
        // potential field switch
        
        let areaCode = areaCodeTextField.text!
        
        if birthDateValid == true && areaCode == "" {
            
            areaCodeTextField.becomeFirstResponder()
        }
    }
    
//MARK: - Area code toolbar methods
    
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
    
//MARK: - Phone number toolbar methods
    
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

extension RegistrationFormViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // empty/valid fields blue mark
        
        if textField == firstNameTextField && firstNameValid == true {
            paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
        else if textField == lastNameTextField && lastNameValid == true {
            paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
        else if textField == birthDateTextField && birthDateValid == true {
            paintCell(for: birthDateTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
        else if textField == areaCodeTextField && areaCodeValid == true {
            paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
        else if textField == phoneNumberTextField && phoneNumberValid == true {
            paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
        }
    }
    
    /// Reacts to a 'first name' text field text change event
    
    @objc func firstNameTextFieldDidChangeEditing() {
        
        let firstName_updated = firstNameTextField.text!
        
        if firstName_updated != "" {
            
            // data validation
            
            let firstName_updated_valid: Bool = ValidationService.isNameValid(firstName_updated)
            
            // result (became invalid)
            
            if firstNameValid == true && firstName_updated_valid == false {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                
                firstNameValid = false
            }
            
            // result (became valid)
            
            else if firstNameValid == false && firstName_updated_valid == true {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                firstNameValid = true
            }
        }
        else {
            
            // invalid became empty
            
            if firstNameValid == false {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                firstNameValid = true
            }
        }
        
        return
    }
    
    /// Reacts to a 'last name' text field text change event
    
    @objc func lastNameTextFieldDidChangeEditing() {
        
        let lastName_updated = lastNameTextField.text!
        
        if lastName_updated != "" {
            
            let lastName_updated_valid = ValidationService.isNameValid(lastName_updated)
            
            if lastNameValid == true && lastName_updated_valid == false {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                
                lastNameValid = false
            }
            else if lastNameValid == false && lastName_updated_valid == true {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                lastNameValid = true
            }
        }
        else {
            
            if lastNameValid == false {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                
                lastNameValid = true
            }
        }
        
        return
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // text field editing end
        
        textField.endEditing(true)
        
        // potential field switch
        
        if textField == firstNameTextField {
            
            let firstName = firstNameTextField.text!
            let lastName = lastNameTextField.text!
            
            if firstName != "" && firstNameValid == true && // first name filled, valid
                lastName == "" {                            // last name empty
                
                lastNameTextField.becomeFirstResponder()
            }
        }
        else if textField == lastNameTextField {
            
            let lastName = lastNameTextField.text!
            let birthDate = birthDateTextField.text!
            
            if lastName != "" && lastNameValid == true &&
                birthDate == "" {
                
                birthDateTextField.becomeFirstResponder()
            }
        }
        
        // delegate's response (text field SHOULD return)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // form field color change (and validation, in case of a birth date text field)
        
        if textField == firstNameTextField {
            
            let firstName = firstNameTextField.text!
            
            if firstName == "" {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)) // <- (light gray)
            }
            else if firstNameValid == true {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // <- (white)
            }
        }
        else if textField == lastNameTextField {
            
            let lastName = lastNameTextField.text!
            
            if lastName == "" {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else if lastNameValid == true {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            }
        }
        else if textField == birthDateTextField {
            
            let birthDate_updated = birthDateTextField.text!
            
            if birthDate_updated == "" {
                
                paintCell(for: birthDateTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else {
                
                // birth date validation
                
                let birthDate_updated_valid = ValidationService.isBirthDateValid(birthDate_updated)
                
                // result (valid)
                
                if birthDate_updated_valid == true {
                    
                    paintCell(for: birthDateTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                    
                    birthDateValid = true
                }
                
                // result (became invalid)
                
                else if birthDateValid == true && birthDate_updated_valid == false {
                    
                    paintCell(for: birthDateTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                    
                    birthDateValid = false
                }
            }
        }
        else if textField == areaCodeTextField {
            
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

extension RegistrationFormViewController {
    
    /// Changes specified cell's label and underline colors to given ones
    
    func paintCell(for textField: UITextField!, with labelColor: UIColor, and underlineColor: UIColor) {
        
        if textField == firstNameTextField {
            
            UIView.animate(withDuration: 0.2) {
                self.firstNameLabel.textColor = labelColor
                self.firstNameTextFieldUnderline.backgroundColor = underlineColor
            }
        }
        else if textField == lastNameTextField {
            
            UIView.animate(withDuration: 0.2) {
                self.lastNameLabel.textColor = labelColor
                self.lastNameTextFieldUnderline.backgroundColor = underlineColor
            }
        }
        else if textField == birthDateTextField {
            
            UIView.animate(withDuration: 0.2) {
                self.birthDateLabel.textColor = labelColor
                self.birthDateTextFieldUnderline.backgroundColor = underlineColor
            }
        }
        else if textField == areaCodeTextField {
            
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

extension RegistrationFormViewController {
    
    /// Checks whether all form fields are valid
    
    func allFieldsValid() -> Bool {
        
        // validness check
        
        let allFieldsValid = (
            firstNameValid == true &&
            lastNameValid == true &&
            birthDateValid == true &&
            areaCodeValid == true &&
            phoneNumberValid == true
        )
        
        if allFieldsValid == false {
            return false
        }
        
        // emptyness check (fields marked as valid could be empty, due to the 'true' default value)
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthDate = birthDateTextField.text!
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        let allFieldsFulfilled = (
            firstName != "" &&
            lastName != "" &&
            birthDate != "" &&
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
            firstNameValid == false ||
            lastNameValid == false ||
            birthDateValid == false ||
            areaCodeValid == false ||
            phoneNumberValid == false
        )
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthDate = birthDateTextField.text!
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        let atLeastOneFieldEmpty = (
            firstName == "" ||
            lastName == "" ||
            birthDate == "" ||
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
        proceedButtonArea.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        proceedButtonLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        proceedButton.isUserInteractionEnabled = true
    }

    /// Disables user interaction on the proceed button, changing its color simultaneously
    
    func lockProceedButton() {
        proceedButtonArea.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
        proceedButtonLabel.textColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 0.7803921569, alpha: 1)
        proceedButton.isUserInteractionEnabled = false
    }
}
