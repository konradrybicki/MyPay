//
//  SCEntranceScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

class SCEntranceScreenViewController: UIViewController {

    public var loggingUsersId: Int16!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ..
    }
    
    @IBAction func unwindArrowPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backspaceKeyPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "presentHomeScreen", sender: self)
    }
}
