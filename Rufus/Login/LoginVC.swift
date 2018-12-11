//
//  LoginVC.swift
//  News
//
//  Created by Tomas Pecuch on 21/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
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
    
    @IBOutlet weak var googleSignInView: GIDSignInButton!
    
    @IBOutlet weak var fbCustomButton: UIButton!
    @IBOutlet weak var staticPagesButton: UIButton!
    
    var authUI: FUIAuth? = FUIAuth.defaultAuthUI()
    var fbLoginButton = FBSDKLoginButton()
    
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth()
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        
        if let auth = authUI {
            auth.delegate = self
            auth.providers = providers
        }
        
        // instantiates google sign in button
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // instantiates facebook sign in button
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email"]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.shared.currentVC = self
    }
    
    // MARK: - Actions
    
    
    /// called when google sign in button is pressed
    ///
    /// - Parameter sender: button which was pressed
    @IBAction func googleSignInAction(_ sender: Any) {
        if let auth = authUI {
            let authViewController = auth.authViewController()
            self.addChildVC(authViewController)
        }
    }
    
    
    /// called when facebook login button was pressed
    ///
    /// - Parameter sender: button which was pressed
    @IBAction func fbLoginAction(_ sender: Any) {
        fbLoginButton.sendActions(for: .touchUpInside)
    }
    
    
    /// called when static page button was pressed
    ///
    /// - Parameter sender: button which was pressed
    @IBAction func staticPagesAction(_ sender: Any) {
        let staticPageVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
        navigationController?.pushViewController(staticPageVC, animated: true)
    }
    
    // FBAuthDelegate

    /// asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    // called when sign in to Firebase finished
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }

    /// called when sign in with google occured
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
    
    // called when presenting google sign in viewController
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("sign present")
    }
    
    // called when dismissing google sing in viewController
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("sign disconnect")
    }
    
    // MARK: - Facebook Login delegate
    
    /// called when facebook login finished
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
    
    /// called when logging out from the facebook
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did logout facebook")
    }
    
    // MARK: - Other
    
    func configurate() {
        logoImageView.image = UIImage(named: Environment().configuration(.logoImageName))
        
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        staticPagesButton.titleLabel!.font = UIFont().configFontOfSize(size: staticPagesButton.titleLabel!.font.pointSize)
        
        titleLabel.font = UIFont().configFontOfSize(size: titleLabel.font.pointSize)
        titleLabel.text = "Welcome to \(appName)"
    }
    
}
