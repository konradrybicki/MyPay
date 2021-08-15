//
//  RegistrationEndScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 01/08/2021.
//

import UIKit

class RegistrationEndScreenViewController: UIViewController {

    @IBOutlet weak var communicate: UILabel!
    @IBOutlet weak var okButtonPreciseArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // (same as in the SCConfigScreenViewController)
        okButtonPreciseArea.layer.cornerRadius = 15
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentWelcomeScreen", sender: self)
    }
}
