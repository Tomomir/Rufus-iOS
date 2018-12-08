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
import FBSDKLoginKit
import JGProgressHUD


class LoginVC: UIViewController, FUIAuthDelegate, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var googleSignInView: GIDSignInButton!
    
    //@IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var fbCustomButton: UIButton!
    var fbLoginButton = FBSDKLoginButton()
    @IBOutlet weak var staticPagesButton: UIButton!
    
    var authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth()
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        titleLabel.text = "Welcome to \(appName)"
        
        if let auth = authUI {
            auth.delegate = self
            auth.providers = providers
        }
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email"]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.shared.currentVC = self
    }
    
    // Actions
    
    @IBAction func googleSignInAction(_ sender: Any) {
        if let auth = authUI {
            let authViewController = auth.authViewController()
            self.addChildVC(authViewController)
        }
    }
    
    @IBAction func fbLoginAction(_ sender: Any) {
        fbLoginButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func staticPagesAction(_ sender: Any) {
        let staticPageVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
        navigationController?.pushViewController(staticPageVC, animated: true)
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
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            // User is signed in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("sign present")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("sign disconnect")
    }
    
    // MARK: - Facebook Login delegate
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if let token = FBSDKAccessToken.current() {
            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential) { [weak self] (authResult, error) in
                if let error = error {
                    print(error)
                    return
                }
                print("did sign in with facebook")
                self?.navigationController?.popViewController(animated: true)
            }
        }
        

    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did logout facebook")
    }
    
}
