//
//  ViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 14/07/2021.
//

import UIKit

class WelcomeScreenViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        
        registerButton.layer.cornerRadius = 15
        registerButton.clipsToBounds = true
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentRegistrationForm", sender: self)
    }
}
