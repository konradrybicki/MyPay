//
//  LogoutScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

/// Controlls the logout screen

class LogoutScreenViewController: UIViewController {
    
    // logout decision confirm buttons
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // button rounding
        
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
    }
    
    @IBAction func noButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButtonPressed(_ sender: UIButton) {
        
        // view change (welcome screen)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeScreenVC = storyboard.instantiateViewController(withIdentifier: "WelcomeScreenViewController") as! WelcomeScreenViewController
        
        welcomeScreenVC.modalPresentationStyle = .fullScreen
        welcomeScreenVC.modalTransitionStyle = .crossDissolve
        
        present(welcomeScreenVC, animated: true) {
            
            // DatabaseListener service stop (account balance updates checking)
            DatabaseListener.stopListeningFor_loggedUsersAccountBalanceUpdate()
            
            // logged user's id "deletion"
            GlobalVariables.currentlyLoggedUsersId = nil
        }
    }
}
