//
//  TopUpFormViewController.swift
//  MyPay
//
//  Created by Konrad Rybicki on 20/09/2021.
//

import UIKit

class TopUpFormViewController: UIViewController {
    
    @IBOutlet weak var amountPreciseArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountPreciseArea.layer.cornerRadius = 15
        amountPreciseArea.clipsToBounds = true
    }
}
