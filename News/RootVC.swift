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
        
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        controllersArray.append(mainVC)

        if API.shared.isLoggedIn() == false {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            controllersArray.append(loginVC)
            self.navigationController?.setViewControllers(controllersArray, animated: true)
        } else {
            self.navigationController?.setViewControllers(controllersArray, animated: true)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func loadEssentialsAndPushVCs(viewControllers: [UIViewController]) {
//        let hud = JGProgressHUD(style: .light)
//        hud.textLabel.text = "Loading"
//        hud.show(in: self.view)
//        hud.dismiss(afterDelay: 10.0)
//        API.shared.loadAllEssentails { [weak self] (success) in
//            hud.dismiss()
//            if success {
//                self?.navigationController?.setViewControllers(viewControllers, animated: true)
//            } else {
//                // TODO: handle error
//            }
//        }
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}
