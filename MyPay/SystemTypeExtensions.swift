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
    
    /// Temporarily adds a white-colored UIView, which contains a single blue-colored, animating Activity Indicator right in the middle, to the ViewController's Superview
    
    public func displayLoadingAnimation() {
        
        // (just to enhance code readability)
        
        let superview = self.view!
        
        defer {
            self.view = superview
        }
        
        // loading view initialization
        
        let loadingView = UIView(frame: superview.bounds)
        loadingView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
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
        
        superview.addSubview(loadingView)
    }
    
    /// Removes a view, added within the displayLoadingAnimation() method, from the ViewController's Superview
    
    public func hideLoadingAnimation() {
        
        let superview = self.view!
        
        defer {
            self.view = superview
        }
        
        // loading view indentification and removal
        
        if let loadingView = superview.viewWithTag(1) {
            loadingView.removeFromSuperview()
        }
    }
}

extension String {
    
    /// Returns a string's value, without the last character
    
    public func droppedLastCharacter() -> String {
        String(self.prefix(self.count-1))
    }
}
