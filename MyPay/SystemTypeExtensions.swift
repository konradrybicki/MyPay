//
//  SystemTypeExtensions.swift
//  MyPay
//
//  Created by Konrad Rybicki on 09/08/2021.
//

import UIKit

extension Int {
    
    /// Optionally returns an ASCII character from an intiger value
    
    public func asAsciiCharacter() -> Character? {
        
        guard let unicodeScalar = UnicodeScalar(self) else {
            print("Error inside Int->asAsciiCharacter() - UnicodeScalar parsing failure for value \(self)")
            return nil
        }
        
        return Character(unicodeScalar)
    }
}

extension UIViewController {
    
    /// Covers the entire screen with a white-colored UIView, which contains a single blue-colored, animating Activity Indicator right in the middle
    
    public static func displayLoadingAnimation() {
        
        // loading view initialization
        
        let loadingView = UIView(frame: UIScreen.main.bounds)
        loadingView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loadingView.tag = 1
        
        // loading indicator initialization
        
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.color = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // loading indicator setup
        
        loadingView.addSubview(loadingIndicator)
        
        let loadingIndicator_horizontalAlignmentConstraint = loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        let loadingIndicator_verticalAlignmentConstraint = loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        
        NSLayoutConstraint.activate([loadingIndicator_horizontalAlignmentConstraint, loadingIndicator_verticalAlignmentConstraint])
        
        loadingIndicator.startAnimating()
        
        // loading animation display
        
        let window = UIApplication.shared.keyWindow!
        
        loadingView.frame = window.bounds
        window.addSubview(loadingView)
    }
    
    /// Removes a view, initialized by the displayLoadingAnimation() method from the screen
    
    public static func hideLoadingAnimation() {
        
        let window = UIApplication.shared.keyWindow!
        
        let loadingView = window.viewWithTag(1)
        loadingView!.removeFromSuperview()
    }
}
