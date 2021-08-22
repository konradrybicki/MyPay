//
//  RegistrationEndScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 01/08/2021.
//

import UIKit

/// Controlls communicate screen, presented programmatically by other view controllers, in purpose of either displaying a "succesful" communicate, or an error

class CommunicateScreenViewController: UIViewController {

    // interface
    @IBOutlet weak var communicate: UILabel!
    @IBOutlet weak var okButtonPreciseArea: UIView!
    
    // a communicate message, initialized manually after vc initialization
    private var message = ""
    public func setMessage(to message: String) {
        self.message = message
    }
    
    // a view controller, which the Communicate Screen will bring user to, in case of a forward screen change
    private var newDestination = ""
    public func setNewDestination(to newDestination: String) {
        self.newDestination = newDestination
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interface look
        communicate.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        okButtonPreciseArea.layer.cornerRadius = 15
        
        // communicate content
        communicate.text = message
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {

        if newDestination != "" {
            
            // TODO: forward screen change
            
        }
        else {
            
            // backward screen change
            
            dismiss(animated: true, completion: nil)
        }
    }
}
