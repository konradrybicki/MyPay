//
//  RegistrationFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 19/07/2021.
//

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
        
        // last validation step - area code and phone number combination ("telephone number") database uniqueness check (for an active account)
        
        let areaCode = areaCodeTextField.text!
        let phoneNumber = phoneNumberTextField.text!
        
        let isNumberUnique: Bool
        
        do {
            isNumberUnique = try MySQLManager.isTelephoneNumberUniqueForAnActiveAccount(areaCode, phoneNumber)
        }
        catch {
            // TODO: error display
            return
        }
        
        if isNumberUnique == true {
            
            // validation complete - user object construction (data "encapsulation")
            
            let firstName = firstNameTextField.text!
            let lastName = lastNameTextField.text!
            let birthDate = birthDateTextField.text!
            let areaCode = areaCodeTextField.text!
            let phoneNumber = phoneNumberTextField.text!
            
            self.user = User(firstName, lastName, birthDate, areaCode, phoneNumber)
                        
            // forward view change, preceded with user object transfer
            
            performSegue(withIdentifier: "presentSCConfigScreen", sender: self)
        }
        else {
            // TODO: error display
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // user object transfer
        
        let destinationVC = segue.destination as! SCConfigScreenViewController
        destinationVC.user = self.user
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
        else {
            print("Property unwrap failed unexpectedely (dateFormatter.date) inside 'createBirthDateDatePicker' method. Unable to set a default date for a date picker")
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
    
        // assignment
        
        birthDateTextField.text = birthDate_formatted
        birthDateTextField.endEditing(true)
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
        
        guard let areaCode = areaCodeTextField.text else {
            
            print("Property unwrap failed unexpectedely (areaCodeTextField.text)")
            
            AudioServicesPlaySystemSound(1104)
            areaCodeTextField.text = "+"
            
            return
        }
        
        if areaCode == "" {
            AudioServicesPlaySystemSound(1104)
            areaCodeTextField.text = "+"
        }
        else {
            let firstCharacter = Array(areaCode)[0]
            
            if firstCharacter != "+" {
                AudioServicesPlaySystemSound(1104)
                areaCodeTextField.text = "+" + areaCode
            }
        }
    }
    
    @objc func areaCodeToolbar_doneButtonPressed() {
        areaCodeTextField.endEditing(true)
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
        
        guard let firstName_updated = firstNameTextField.text else {
            print("Error inside RegistrationFormViewController->firstNameTextFieldDidChangeEditing() - unexpected unwrap failure for 'firstNameTextField.text' property")
            // TODO: error display
            return
        }
        
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
        
        guard let lastName_updated = lastNameTextField.text else {
            print("Error inside RegistrationFormViewController->lastNameTextFieldDidChangeEditing() - unexpected unwrap failure for 'lastNameTextField.text' property")
            // TODO: error display
            return
        }
        
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
        
        guard let areaCode_updated = areaCodeTextField.text else {
            print("Error inside RegistrationFormViewController->areaCodeTextFieldDidChangeEditing() - unexpected unwrap failure for 'areaCodeTextField.text' property")
            // TODO: error handling
            return
        }
        
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
        
        return
    }
    
    /// Reacts to a 'phone number' text field text change event
    
    @objc func phoneNumberTextFieldDidChangeEditing() {
        
        guard let phoneNumber_updated = phoneNumberTextField.text else {
            print("Error inside RegistrationFormViewController->phoneNumberTextFieldDidChangeEditing() - unexpected unwrap failure for 'phoneNumberTextField.text' property")
            // TODO: error handling
            return
        }
        
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
        
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // first name text field editing end
        
        if textField == firstNameTextField {
            
            guard let firstName = firstNameTextField.text else {
                print("Error inside RegistrationFormViewController->textFieldDidEndEditing() - unexpected unwrap failure for 'firstNameTextField.text' property")
                // TODO: error handling
                return
            }
            
            if firstName == "" {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)) // <- (light gray)
            }
            else if firstNameValid == true {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // <- (white)
                
                // potential field switch
                
                guard let lastName = lastNameTextField.text else {
                    print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'first name text field editing end' - unexpected unwrap failure for 'lastNameTextField.text' property")
                    // TODO: error handling
                    return
                }
                
                if lastName == "" {
                    lastNameTextField.becomeFirstResponder()
                }
            }
        }
        
        // last name text field editing end
        
        else if textField == lastNameTextField {
            
            guard let lastName = lastNameTextField.text else {
                print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'last name text field editing end' - unexpected unwrap failure for 'lastNameTextField.text' property")
                // TODO: error handling
                return
            }
            
            if lastName == "" {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else if lastNameValid == true {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                
                guard let birthDate = birthDateTextField.text else {
                    print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'last name text field editing end' - unexpected unwrap failure for 'birthDateTextField.text' property")
                    // TODO: error handling
                    return
                }
                
                if birthDate == "" {
                    birthDateTextField.becomeFirstResponder()
                }
            }
        }
        
        // 'birth date text field editing end'
        
        else if textField == birthDateTextField {
            
            guard let birthDate_updated = birthDateTextField.text else {
                print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'birth date text field editing end' - unexpected unwrap failure for 'birthDateTextField.text' property")
                // TODO: error display
                return
            }
            
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
                    
                    guard let areaCode = areaCodeTextField.text else {
                        print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'birth date text field editing end' - unexpected unwrap failure for 'areaCodeTextField.text' property")
                        // TODO: error display
                        return
                    }
                    
                    if areaCode == "" {
                        areaCodeTextField.becomeFirstResponder()
                    }
                }
                
                // result (became invalid)
                
                else if birthDateValid == true && birthDate_updated_valid == false {
                    
                    paintCell(for: birthDateTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                    
                    birthDateValid = false
                }
            }
        }
        
        // area code text field editing end
        
        else if textField == areaCodeTextField {
            
            guard let areaCode = areaCodeTextField.text else {
                print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'area code text field editing end' - unexpected unwrap failure for 'areaCodeTextField.text' property")
                // TODO: error display
                return
            }
            
            if areaCode == "" {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1))
            }
            else if areaCodeValid == true {
                
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                
                guard let phoneNumber = phoneNumberTextField.text else {
                    print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'area code text field editing end' - unexpected unwrap failure for 'phoneNumberTextField.text' property")
                    // TODO: error display
                    return
                }
                
                if phoneNumber == "" {
                    phoneNumberTextField.becomeFirstResponder()
                }
            }
        }
        
        // phone number text field editing end
        
        else if textField == phoneNumberTextField {
            
            guard let phoneNumber = phoneNumberTextField.text else {
                print("Error inside RegistrationFormViewController->textFieldDidEndEditing()->'phone number text field editing end' - unexpected unwrap failure for 'phoneNumberTextField.text' property")
                // TODO: error display
                return
            }
            
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
            firstNameLabel.textColor = labelColor
            firstNameTextFieldUnderline.backgroundColor = underlineColor
        }
        else if textField == lastNameTextField {
            lastNameLabel.textColor = labelColor
            lastNameTextFieldUnderline.backgroundColor = underlineColor
        }
        else if textField == birthDateTextField {
            birthDateLabel.textColor = labelColor
            birthDateTextFieldUnderline.backgroundColor = underlineColor
        }
        else if textField == areaCodeTextField {
            areaCodeLabel.textColor = labelColor
            areaCodeTextFieldUnderline.backgroundColor = underlineColor
        }
        else {
            phoneNumberLabel.textColor = labelColor
            phoneNumberTextFieldUnderline.backgroundColor = underlineColor
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
        
        // (mutual unwrap)
        
        let allFieldsFulfilled_wrapped: Bool? = (
            firstNameTextField.text != "" &&
            lastNameTextField.text != "" &&
            birthDateTextField.text != "" &&
            areaCodeTextField.text != "" &&
            phoneNumberTextField.text != ""
        )
        
        guard let allFieldsFulfilled = allFieldsFulfilled_wrapped else {
            print("Error inside RegistrationFormViewController->allFieldsValid() - unexpected unwrap failure for 'textField.text' property")
            // TODO: error display
        }
            
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
        
        let atLeastOneFieldEmpty_wrapped: Bool? = (
            firstNameTextField.text == "" ||
            lastNameTextField.text == "" ||
            birthDateTextField.text == "" ||
            areaCodeTextField.text == "" ||
            phoneNumberTextField.text == ""
        )
        
        guard let atLeastOneFieldEmpty = atLeastOneFieldEmpty_wrapped else {
            print("Error inside RegistrationFormViewController->atLeastOneFieldInvalidOrEmpty() - unexpected unwrap failure for 'textField.text' property")
            // TODO: error display
        }
        
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
