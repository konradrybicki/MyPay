//
//  RegistrationFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 19/07/2021.
//

import UIKit
import AudioToolbox // area code toolbar plus button press sound

class RegistrationFormViewController: UIViewController {
    
    @IBOutlet weak var firstNameArea: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameTextFieldUnderline: UIView!
    
    @IBOutlet weak var lastNameArea: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameTextFieldUnderline: UIView!
    
    @IBOutlet weak var birthDateArea: UIView!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var birthDateTextFieldUnderline: UIView!
    var birthDateToolbar: UIToolbar!
    var birthDateDatePicker: UIDatePicker!
    
    @IBOutlet weak var areaCodeArea: UIView!
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaCodeTextFieldUnderline: UIView!
    var areaCodeToolbar: UIToolbar!
    
    @IBOutlet weak var phoneNumberArea: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberTextFieldUnderline: UIView!
    var phoneNumberToolbar: UIToolbar!
    
    @IBOutlet weak var proceedButtonArea: UIView!
    
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
        
        guard let text = textField.text else {
            print("Property unwrap failed unexpectedely (\(textField).text) inside 'textFieldDidBeginEditing' method")
            return
        }
        
        if text != "" {
            
            if textField == firstNameTextField {
                firstNameTextFieldUnderline.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
            }
            else if textField == lastNameTextField {
                lastNameTextFieldUnderline.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
            }
            else if textField == birthDateTextField {
                birthDateTextFieldUnderline.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
            }
            else if textField == areaCodeTextField {
                areaCodeTextFieldUnderline.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
            }
            else if textField == phoneNumberTextField {
                phoneNumberTextFieldUnderline.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text else {
            print("Property unwrap failed unexpectedely (\(textField).text) inside 'textFieldDidEndEditing' method")
            return
        }
        
        if text != "" {
        
            // TODO: gramatical name correction
            if textField == firstNameTextField ||
               textField == lastNameTextField {
                
                //..
                
            }
            
            // underline hide, optional field switch
            if textField == firstNameTextField {
                
                firstNameTextFieldUnderline.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                if lastNameTextField.text == "" {
                    lastNameTextField.becomeFirstResponder()
                }
            }
            else if textField == lastNameTextField {
                
                lastNameTextFieldUnderline.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                if birthDateTextField.text == "" {
                    birthDateTextField.becomeFirstResponder()
                }
            }
            else if textField == birthDateTextField {
                
                birthDateTextFieldUnderline.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                if areaCodeTextField.text == "" {
                    areaCodeTextField.becomeFirstResponder()
                }
            }
            else if textField == areaCodeTextField {
                
                areaCodeTextFieldUnderline.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                if phoneNumberTextField.text == "" {
                    phoneNumberTextField.becomeFirstResponder()
                }
            }
            else if textField == phoneNumberTextField {
                phoneNumberTextFieldUnderline.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
}
