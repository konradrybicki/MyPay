//
//  RegistrationEndScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 01/08/2021.
//

import UIKit

/// Controlls communicate screen, which displays either a "succesful" message or an error to the end user

class CommunicateScreenViewController: UIViewController {

    // interface
    @IBOutlet weak var communicate: UILabel!
    @IBOutlet weak var okButtonPreciseArea: UIView!
    
    // a message, displayed to the user
    private var communicateMessage: String!
    
    // a view controller, presented upon tapping an 'ok' button, in case of a forward screen change
    private var newDestinationVC: String?
    
    // data passed to a new destination vc, right before it's presentation
    private var newDestinationData: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interface look
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        okButtonPreciseArea.layer.cornerRadius = 15
        
        // communicate message
        communicate.text = communicateMessage
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        
        if let newDestinationVC = self.newDestinationVC { // (forward screen change)
            
            // storyboard instantiation
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if newDestinationVC == "WelcomeScreenViewController" {
                
                // destination vc instantiation attempt
                let welcomeScreenVC_wrapped = storyboard.instantiateViewController(withIdentifier: "WelcomeScreenViewController") as? WelcomeScreenViewController
                
                // result unwrap
                guard let welcomeScreenVC = welcomeScreenVC_wrapped else {
                    print("Error inside CommunicateScreenViewController->okButtonPressed() - unexpected unwrap failure for 'welcomeScreenVC_wrapped' constant")
                    exit(1)
                }
                
                // destination vc presentation style
                welcomeScreenVC.modalPresentationStyle = .fullScreen
                
                // destination vc presentation
                present(welcomeScreenVC, animated: true, completion: nil)
            }
        }
        else { // (backward screen change)
            
            dismiss(animated: true, completion: nil)
        }
    }
}

extension CommunicateScreenViewController {
    
    /// Acts as an initializer, returning an instance of a CommunicateScreenViewController that, upon tapping an 'ok' button, will take the user back to a presenting view controller
    
    public static func instantiateVC(withCommunicate communicate: String) -> CommunicateScreenViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let communicateScreenVCInstance_wrapped = storyboard.instantiateViewController(withIdentifier: "CommunicateScreenViewController") as? CommunicateScreenViewController
        
        guard let communicateScreenVCInstance = communicateScreenVCInstance_wrapped else {
            print("Error inside CommunicateScreenViewController.instantiateVC(withCommunicate) - unexpected unwrap failure for 'communicateScreenVCInstance_wrapped' constant")
            exit(1)
        }
        
        // initial setup
        communicateScreenVCInstance.communicateMessage = communicate
        
        // presentation style
        communicateScreenVCInstance.modalPresentationStyle = .fullScreen
        
        return communicateScreenVCInstance
    }
    
    /// Acts as an initializer, returning an instance of a CommunicateScreenViewController that, upon tapping an 'ok' button, will take the user to a specified view controller
    
    public static func instantiateVC(withCommunicate communicate: String, andNewDestinationVC newDestinationVC: String) -> CommunicateScreenViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let communicateScreenVCInstance_wrapped = storyboard.instantiateViewController(withIdentifier: "CommunicateScreenViewController") as? CommunicateScreenViewController
        
        guard let communicateScreenVCInstance = communicateScreenVCInstance_wrapped else {
            print("Error inside CommunicateScreenViewController.instantiateVC(withCommunicate, andNewDestination) - unexpected unwrap failure for 'communicateScreenVCInstance_wrapped' constant")
            exit(1)
        }
        
        communicateScreenVCInstance.communicateMessage = communicate
        communicateScreenVCInstance.newDestinationVC = newDestinationVC
        
        communicateScreenVCInstance.modalPresentationStyle = .fullScreen
        
        return communicateScreenVCInstance
    }
    
    /// Acts as an initializer, returning an instance of a CommunicateScreenViewController that, upon tapping an 'ok' button, will take the user to a specified view controller, initializing it with given data
    
    public static func instantiateVC(withCommunicate communicateMessage: String, andNewDestinationVC newDestinationVC: String, passingData newDestinationData: Any) -> CommunicateScreenViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let communicateScreenVCInstance_wrapped = storyboard.instantiateViewController(withIdentifier: "CommunicateScreenViewController") as? CommunicateScreenViewController
        
        guard let communicateScreenVCInstance = communicateScreenVCInstance_wrapped else {
            print("Error inside CommunicateScreenViewController.instantiateVC(withCommunicate, andNewDestination, passingData) - unexpected unwrap failure for 'communicateScreenVCInstance_wrapped' constant")
            exit(1)
        }
        
        communicateScreenVCInstance.communicateMessage = communicateMessage
        communicateScreenVCInstance.newDestinationVC = newDestinationVC
        communicateScreenVCInstance.newDestinationData = newDestinationData
        
        communicateScreenVCInstance.modalPresentationStyle = .fullScreen
        
        return communicateScreenVCInstance
    }
}
