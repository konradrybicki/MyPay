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
    
    // a view controller, presented upon tapping an 'ok' button, in case of a forward screen change
    private var newDestinationVC: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        okButtonPreciseArea.layer.cornerRadius = 15
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {

        if let newDestinationVC = self.newDestinationVC {
            
            // TODO: forward screen change
            
        }
        else {
            // backward screen change
            dismiss(animated: true, completion: nil)
        }
    }
}

extension CommunicateScreenViewController {
    
    /// Acts as an initializer, returning an instance of a CommunicateScreenViewController, instantiated from a storyboard constant
    
    public static func instantiateVC(withCommunicate communicate: String) -> CommunicateScreenViewController {
        
        // storyboard instantiation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // vc instantiation attempt
        let communicateScreenVCInstance_wrapped = storyboard.instantiateViewController(withIdentifier: "CommunicateScreenViewController") as? CommunicateScreenViewController
        
        // result unwrap
        guard let communicateScreenVCInstance = communicateScreenVCInstance_wrapped else {
            print("Error inside CommunicateScreenViewController.instantiateVC(withCommunicate) - unexpected unwrap failure for 'communicateScreenVCInstance_wrapped' constant")
            exit(1)
        }
        
        // vc setup
        communicateScreenVCInstance.communicate.text = communicate
        
        return communicateScreenVCInstance
    }
    
    /// Acts as an initializer, returning an instance of a CommunicateScreenViewController, instantiated from a storyboard constant
    
    public static func instantiateVC(withCommunicate communicate: String, andNewDestinationVC newDestinationVC: String) -> CommunicateScreenViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let communicateScreenVCInstance_wrapped = storyboard.instantiateViewController(withIdentifier: "CommunicateScreenViewController") as? CommunicateScreenViewController
        
        guard let communicateScreenVCInstance = communicateScreenVCInstance_wrapped else {
            print("Error inside CommunicateScreenViewController.instantiateVC(withCommunicate, andNewDestination) - unexpected unwrap failure for 'communicateScreenVCInstance_wrapped' constant")
            exit(1)
        }
        
        communicateScreenVCInstance.communicate.text = communicate
        communicateScreenVCInstance.newDestinationVC = newDestinationVC
        
        return communicateScreenVCInstance
    }
}
