//
//  LoginVC.swift
//  News
//
//  Created by Tomas Pecuch on 21/10/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import GoogleSignIn

class LoginVC: UIViewController, FUIAuthDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var googleSignInView: GIDSignInButton!
    
    var authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth()
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = authUI {
            auth.delegate = self
            auth.providers = providers
        }
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    // Actions
    
    @IBAction func googleSignInAction(_ sender: Any) {
        if let auth = authUI {
            let authViewController = auth.authViewController()
            self.addChildVC(authViewController)
        }
    }
    

    // FBAuthDelegate

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("did sign in")
        // initiate and push main view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("sign present")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("sign disconnect")
    }
}
