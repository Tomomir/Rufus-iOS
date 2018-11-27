//
//  CreditsVC.swift
//  News
//
//  Created by Tomas Pecuch on 08/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

class CreditsVC: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    @IBOutlet weak var navigationBackButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func purchaseAction(_ sender: Any) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
}
