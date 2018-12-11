//
//  LoadingButton.swift
//  News
//
//  Created by Tomas Pecuch on 07/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

/// Button that is able to show activity indicator inside its view
class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    
    /// shows loading indicator inside the button
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    
    /// hides loading indicator inside the button
    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    
    /// return instatiated activity  indicator object
    ///
    /// - Returns: activity indicator object
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }
    
    
    /// shows spinning animation
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    
    /// centers activity indiccator to the center of the button
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
