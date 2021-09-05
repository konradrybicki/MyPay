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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
