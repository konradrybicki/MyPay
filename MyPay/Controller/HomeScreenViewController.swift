//
//  HomeScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var account: UIView!
    @IBOutlet weak var topUpButton: UIButton!
    
    @IBOutlet weak var balance_integerPart: UILabel!
    @IBOutlet weak var balance_decimalPart: UILabel!
    
    public var balance_displayReady: (integerPart: String, decimalPart: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appLogo.layer.cornerRadius = 7
        appLogo.clipsToBounds = true
        
        account.layer.cornerRadius = 15
        account.clipsToBounds = true
        
        topUpButton.layer.cornerRadius = 10
        topUpButton.clipsToBounds = true
        
        if let balance_displayReady = balance_displayReady {
            
            balance_integerPart.text = balance_displayReady.integerPart
            balance_decimalPart.text = "." + balance_displayReady.decimalPart
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentLogoutScreen", sender: self)
    }
}
