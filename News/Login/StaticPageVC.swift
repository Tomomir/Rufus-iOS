//
//  StaticPageVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class StaticPageVC: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentTextViewHeightConts: NSLayoutConstraint!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    var data: StaticPageData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearLabelsAndTextView()
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = ""
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 10.0)
        
        API.shared.getFullStaticPageDict { [weak self] (result) in
            hud.dismiss()
            switch result {
            case .failure(let error):
                // TODO: handle error
                print(error)
            case .success(let pageData):
                if let firstPageData = pageData.first {
                    self?.data = firstPageData
                    self?.fillData()
                } else {
                    // TODO: handle error here
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func acceptAction(_ sender: Any) {
        //TODO: mark page as accepted
        if let userID = Auth.auth().currentUser?.uid {
            API.shared.saveStaticPageAcceptance(userID: userID)
            //navigationController?.popToRootViewController(animated: true)
            self.loadEssentialsAndPopVC()
        } else {
            // TODO: handle error here
        }
    }
    
    
    // MARK: - Other

    func fillData() {
        guard let dataStruct = data else { return }
        self.titleLabel.text = dataStruct.title
        self.subtitleLabel.text = dataStruct.subTitle

        let text = API.shared.convertToDictionary(text: dataStruct.text)
        let blocks = text!["blocks"] as! [[String : Any]]
        var finalText: String = ""

        for block in blocks {
            finalText.append(block["text"] as! String)
            finalText.append("\n\n")
        }
        contentTextView.text = finalText
        contentTextViewHeightConts.constant = contentTextView.contentSize.height
    }
    
    func clearLabelsAndTextView() {
        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        self.contentTextView.text = ""
    }
    
    func loadEssentialsAndPopVC() {
//        let hud = JGProgressHUD(style: .light)
//        hud.textLabel.text = "Loading"
//        hud.show(in: self.view)
//        hud.dismiss(afterDelay: 10.0)
//        API.shared.loadAllEssentails { [weak self] (success) in
//            hud.dismiss()
//            if success {
//            } else {
//                // TODO: handle error
//            }
//        }
        self.navigationController?.popToRootViewController(animated: true)

    }

}
