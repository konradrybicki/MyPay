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
        
        // loading animation display
        displayLoadingAnimation()
        
        // account balance updates listening stop
        DatabaseListener.delegate = self
        DatabaseListener.stopListening()
    }
}

extension LogoutScreenViewController: DatabaseListenerDelegate {
    
    func databaseListenerDidEndListening() {
        
        // DatabaseListener error display permit (will be able to display errors again, after the user logs in)
        
        DatabaseListener.displayErrors()
        
        // view change (welcome screen)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeScreenVC = storyboard.instantiateViewController(withIdentifier: "WelcomeScreenViewController") as! WelcomeScreenViewController
        
        welcomeScreenVC.modalPresentationStyle = .fullScreen
        welcomeScreenVC.modalTransitionStyle = .crossDissolve
        
        present(welcomeScreenVC, animated: true) {
            
            // logged user's data cleanup
            GlobalVariables.loggedUsersId = nil
            GlobalVariables.loggedUsersSCHash = nil
            GlobalVariables.loggedUsersSCSalt = nil
            GlobalVariables.loggedUsersAccountNumber = nil
            GlobalVariables.loggedUsersAccountBalance = nil
            
            // loading animation hide
            self.hideLoadingAnimation()
        }
    }
}
