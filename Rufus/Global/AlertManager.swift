//
//  AlertManager.swift
//  News
//
//  Created by Tomas Pecuch on 04/12/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    
    // singleton
    static var shared = AlertManager()
    var currentVC: UIViewController?

    
    /// shows alert to the currently presented view
    ///
    /// - Parameters:
    ///   - title: title of the alert
    ///   - text: text of the alert
    func showBasicAlert(title: String, text: String) {
        guard let vc = currentVC else { return }
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
