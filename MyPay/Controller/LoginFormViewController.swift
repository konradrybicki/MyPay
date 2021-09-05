//
//  LoginFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 03/09/2021.
//

import UIKit

class LoginFormViewController: UIViewController {

    @IBOutlet weak var areaCodeArea: UIView!
    @IBOutlet weak var phoneNumberArea: UIView!
    @IBOutlet weak var proceedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        areaCodeArea.layer.cornerRadius = 15
        areaCodeArea.clipsToBounds = true
        
        phoneNumberArea.layer.cornerRadius = 15
        phoneNumberArea.clipsToBounds = true
        
        proceedButton.layer.cornerRadius = 15
        proceedButton.clipsToBounds = true
        
        proceedButton.isUserInteractionEnabled = true
    }
    
    @IBAction func unwindArrowPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentSCEntranceScreen", sender: self)
    }
}
