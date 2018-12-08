//
//  ArticleCollectionCell.swift
//  News
//
//  Created by Tomas Pecuch on 19/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class ArticleCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let titleColor = Environment().configuration(.titleColor).hexStringToUIColor()
        titleLabel.textColor = titleColor
    }
}
