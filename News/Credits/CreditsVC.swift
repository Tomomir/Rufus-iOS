//
//  CreditsVC.swift
//  News
//
//  Created by Tomas Pecuch on 08/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import JGProgressHUD

class CreditsVC: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    @IBOutlet weak var navigationBackButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var creditIconImageView: UIImageView!
    
    private var progressHUD: JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        IAPHandler.shared.purchaseStatusBlock = { [weak self] (type) in
            self?.hideLoading()
            if type == .purchased {
                API.shared.addCredits(completion: { (success) in
                    switch success {
                    case true:
                        print("credits added")
                    case false:
                        print("credits failed to add")
                    }
                })  
            }
        }
        self.setCredits()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateCredits(notification:)), name: Notification.Name("credits_updated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    
    /// called when back button is pressed
    ///
    /// - Parameter sender: button object which was pressed
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    /// called when purchase button is pressed
    ///
    /// - Parameter sender: button object which was pressed
    @IBAction func purchaseAction(_ sender: Any) {
        if IAPHandler.shared.areProductLoaded() {
            self.showLoading()
            IAPHandler.shared.purchaseMyProduct(index: 0)
        }
        
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        let buttonColor = Environment().configuration(.buttonColor).hexStringToUIColor()
        purchaseButton.backgroundColor = buttonColor
    }
    
    /// sets current credit count
    func setCredits() {
        let credits = CreditsDataSource.shared.numberOfCredits
        self.creditsLabel.text = "\(credits)"
    }
    
    
    /// updates current credits count when notification arrives
    ///
    /// - Parameter notification: notification which indicates credit count change
    @objc func updateCredits(notification: NSNotification) {
        let credits = CreditsDataSource.shared.numberOfCredits
        creditsLabel.text = "\(credits)"
    }
    
    /// shows loading indicator
    func showLoading() {
        progressHUD = JGProgressHUD(style: .light)
        progressHUD?.textLabel.text = ""
        progressHUD?.show(in: self.view)
    }
    
    /// hides loading indicator
    func hideLoading() {
        if let hud = progressHUD {
            hud.dismiss()
        }
    }
}
