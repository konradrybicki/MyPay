//
//  ViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 14/07/2021.
//

import UIKit

/// Controlls welcome screen

class WelcomeScreenViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // login button appearance
        loginButton.layer.cornerRadius = 15
        loginButton.clipsToBounds = true
        
        // register button appearance
        registerButton.layer.cornerRadius = 15
        registerButton.clipsToBounds = true
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentLoginForm", sender: self)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentRegistrationForm", sender: self)
    }
}
