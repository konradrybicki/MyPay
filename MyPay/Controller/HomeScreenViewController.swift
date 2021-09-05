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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appLogo.layer.cornerRadius = 7
        appLogo.clipsToBounds = true
        
        account.layer.cornerRadius = 15
        account.clipsToBounds = true
        
        topUpButton.layer.cornerRadius = 10
        topUpButton.clipsToBounds = true
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentLogoutScreen", sender: self)
    }
}
