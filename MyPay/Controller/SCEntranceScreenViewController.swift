//
//  SCEntranceScreenViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 04/09/2021.
//

import UIKit

class SCEntranceScreenViewController: UIViewController {

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
