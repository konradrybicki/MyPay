//
//  RegistrationFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 19/07/2021.
//

import UIKit
import AudioToolbox // area code toolbar plus button press sound

class RegistrationFormViewController: UIViewController {
    
    // interface
    
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
    
    @IBOutlet weak var proceedButtonArea: UIView!
    
    // data validation
    
    var firstNameValid: Bool = true
    var lastNameValid: Bool = true
    var birthDateValid: Bool = true
    var areaCodeValid: Bool = true
    var phoneNumberValid: Bool = true
    
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
        
        // "typeable" text fields text change capture
        firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidChangeEditing), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidChangeEditing), for: .editingChanged)
        areaCodeTextField.addTarget(self, action: #selector(areaCodeTextFieldDidChangeEditing), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChangeEditing), for: .editingChanged)
    }
    
    // navigation
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentSCConfigScreen", sender: self)
    }
    
//MARK: - Birth date date picker and toolbar methods
    
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
        
        // color change for empty/valid fields (..valid == true)
        
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
    
    // custom text field methods for editing change
    
    @objc func firstNameTextFieldDidChangeEditing() {
        
        guard let updatedFirstName = firstNameTextField.text else {
            print("Error inside RegistrationFormViewController->firstNameTextFieldDidChangeEditing() - unexpected unwrap failure for 'firstNameTextField.text' property")
            // TODO: error display
            return
        }
        
        if updatedFirstName != "" {
            
            // validation
            
            let updatedFirstNameValid: Bool = isNameValid(updatedFirstName)
            
            // result (became invalid)
            
            if firstNameValid == true && updatedFirstNameValid == false {
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                firstNameValid = false
            }
            
            // result (became valid)
            
            else if firstNameValid == false && updatedFirstNameValid == true {
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
    
    @objc func lastNameTextFieldDidChangeEditing()  {
        
        guard let updatedLastName = lastNameTextField.text else {
            print("Error inside RegistrationFormViewController->lastNameTextFieldDidChangeEditing() - unexpected unwrap failure for 'lastNameTextField.text' property")
            // TODO: error display
            return
        }
        
        if updatedLastName != "" {
            
            let updatedLastNameValid = isNameValid(updatedLastName)
            
            if lastNameValid == true && updatedLastNameValid == false {
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                lastNameValid = false
            }
            else if lastNameValid == false && updatedLastNameValid == true {
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
    
    @objc func areaCodeTextFieldDidChangeEditing() {
        
        guard let updatedAreaCode = areaCodeTextField.text else {
            print("Error inside RegistrationFormViewController->areaCodeTextFieldDidChangeEditing() - unexpected unwrap failure for 'areaCodeTextField.text' property")
            // TODO: error display
            return
        }
        
        if updatedAreaCode != "" {
            
            let updatedAreaCodeValid = isAreaCodeValid(updatedAreaCode)
            
            if areaCodeValid == true && updatedAreaCodeValid == false {
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                areaCodeValid = false
            }
            else if areaCodeValid == false && updatedAreaCodeValid == true {
                paintCell(for: areaCodeTextField, with: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1), and: #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1))
                areaCodeValid = true
            }
        }
        
        return
    }
    
    @objc func phoneNumberTextFieldDidChangeEditing() {
        
        guard let updatedPhoneNumber = phoneNumberTextField.text else {
            print("Error inside RegistrationFormViewController->phoneNumberTextFieldDidChangeEditing() - unexpected unwrap failure for 'phoneNumberTextField.text' property")
            // TODO: error display
            return
        }
        
        if updatedPhoneNumber != "" {
            
            let updatedPhoneNumberValid = isPhoneNumberValid(updatedPhoneNumber)
            
            if phoneNumberValid == true && updatedPhoneNumberValid == false {
                paintCell(for: phoneNumberTextField, with: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1), and: #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1))
                phoneNumberValid = false
            }
            else if phoneNumberValid == false && updatedPhoneNumberValid == true {
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
        
        guard let text = textField.text else {
            // TODO: text field specification
            print("Error inside RegistrationFormViewController->textFieldDidEndEditing() - unexpected unwrap failure for 'textField.text' property")
            // TODO: error display
            return
        }
        
        if text == "" {
            paintCell(for: textField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)) // (grey and GREY)
        }
        else {
            if textField == firstNameTextField && firstNameValid == true {
                
                paintCell(for: firstNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // (grey and WHITE)
                
                // field "jump"
                
                if lastNameTextField.text == "" {
                    lastNameTextField.becomeFirstResponder()
                }
            }
            else if textField == lastNameTextField && lastNameValid == true {
                
                paintCell(for: lastNameTextField, with: #colorLiteral(red: 0.4980392157, green: 0.5490196078, blue: 0.5529411765, alpha: 1), and: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                
                if birthDateTextField.text == "" {
                    birthDateTextField.becomeFirstResponder()
                }
            }
            else if textField == birthDateTextField {
                
                // ..
                
            }
            else if textField == areaCodeTextField {
                
                // ..
                
            }
            else if textField == phoneNumberTextField && phoneNumberValid == true {
                
                // ..
                
            }
        }
    }
}

//MARK: - Validation methods

extension RegistrationFormViewController {
    
    func isNameValid(_ name: String) -> Bool {
        
        // submethods - length
        
        func isNameLengthValid() -> Bool {
            (1...20).contains(name.count)
        }
        
        // submethods - permitted characters
        
        func isSpace(_ character: Character) -> Bool {
            character.asciiValue! == 32
        }
        
        func isApostrophe(_ character: Character) -> Bool {
            [39, 96].contains(character.asciiValue!)
        }
        
        func isDash(_ character: Character) -> Bool {
            character.asciiValue! == 45
        }
        
        func isUpperCasedLetter(_ character: Character) -> Bool {
            (65...90).contains(character.asciiValue!)
        }
        
        func isLowerCasedLetter(_ character: Character) -> Bool {
            (97...122).contains(character.asciiValue!)
        }
        
        // submethods - character validation
        
        func isValid(_ character: Character) -> Bool {
            
            if character.isASCII == false {
                return false
            }
            else {
                if isSpace(character) == true ||
                   isApostrophe(character) == true ||
                   isDash(character) == true ||
                   isUpperCasedLetter(character) == true ||
                   isLowerCasedLetter(character) == true {
                    
                    return true
                }
                else {
                    return false
                }
            }
        }
        
        // actual validation
        
        if isNameLengthValid() == false {
            return false
        }
        
        for character in name {
            if isValid(character) == false {
                return false
            }
        }
        
        return true
    }
    
    func removeMultipleSpaces(fromName name: inout String) {
        name = name.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
    }
    
    func isBirthDateValid(_ birthDate: String) -> Bool {
        
        if birthDate == "" {
            return false
        }
        
        // birth year (int)
        
        let birthYear_str = String(birthDate.prefix(4))
        
        guard let birthYear_int = Int(birthYear_str) else {
            print("Error inside RegistrationFormViewController->isBirthDateValid() - String->Int parsing failure (birth year)")
            // TODO: error display
            return false
        }
        
        // current year (int)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = dateFormatter.string(from: Date())
        
        let currentYear_str = String(currentDate.prefix(4))
        
        guard let currentYear_int = Int(currentYear_str) else {
            print("Error inside RegistrationFormViewController->isBirthDateValid() - String->Int parsing failure (current year)")
            // TODO: error display
            return false
        }
        
        // users age calculation (the user has to be at least 16 to register)
        
        let usersAge = currentYear_int - birthYear_int
        
        if usersAge >= 16 {
            return true
        }
        else {
            return false
        }
    }
    
    func isAreaCodeValid(_ areaCode: String) -> Bool {
        (1...5).contains(areaCode.count)
    }
    
    func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        (1...10).contains(phoneNumber.count)
    }
    
    func isTelephoneNumberUniqueForAnActiveAccount(_ areaCode: String, _ phoneNumber: String) throws -> Bool {
        try MySQLManager.isTelephoneNumberUniqueForAnActiveAccount(areaCode, phoneNumber)
    }

//MARK: - Cell painting method

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
