//
//  StaticPageVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

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

        self.fillData()
    }
    
    // MARK: - Actions
    
    @IBAction func acceptAction(_ sender: Any) {
        //TODO: mark page as accepted
        
        navigationController?.popViewController(animated: true)
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

}
