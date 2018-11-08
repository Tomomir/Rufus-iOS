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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
