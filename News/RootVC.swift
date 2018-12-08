//
//  RootVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import JGProgressHUD

class RootVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var controllersArray = [UIViewController]()
        
        // add main viewcontroller to the stack
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        controllersArray.append(mainVC)

        // add also loginviewcontroller if not logged in
        if API.shared.isLoggedIn() == false {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            controllersArray.append(loginVC)
            self.navigationController?.setViewControllers(controllersArray, animated: true)
        } else {
            self.navigationController?.setViewControllers(controllersArray, animated: true)
        }
    }

}
