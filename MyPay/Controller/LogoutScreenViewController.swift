//
//  LogoutScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

class LogoutScreenViewController: UIViewController {

    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
    }
    
    @IBAction func noButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButtonPressed(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeScreenVC = storyboard.instantiateViewController(withIdentifier: "WelcomeScreenViewController") as! WelcomeScreenViewController
        
        welcomeScreenVC.modalPresentationStyle = .fullScreen
        welcomeScreenVC.modalTransitionStyle = .crossDissolve
        
        present(welcomeScreenVC, animated: true, completion: nil)
    }
}
