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

        //shows activity indicatior
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 10.0)
        
        //download essentials needed before starting
        API.shared.getFullStaticPageDict { [weak self] (result) in
            switch result {
            case .success(let pageArray):
                hud.dismiss(animated: true)
                var controllersArray = [UIViewController]()
                
                
                
                // initiate and adds main view controller
                let mainVC = self?.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                controllersArray.append(mainVC)
                let hambMenuVC = self?.storyboard?.instantiateViewController(withIdentifier: "HamburgerMenuVC") as! HamburgerMenuVC
                
                for pageData in pageArray {
                    let pageVC = self?.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
                    pageVC.data = pageData
                    controllersArray.append(pageVC)
                }
                
                
                if API.shared.isLoggedIn() == true {
                    let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    controllersArray.append(loginVC)
                }
                

                
                self?.navigationController?.setViewControllers(controllersArray, animated: true)
                
            case .failure(let error):
                //TODO: handle error
                print("error getting page dict: \(error)")
            }
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

}
