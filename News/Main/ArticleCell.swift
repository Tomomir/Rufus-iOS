//
//  ArticleCell.swift
//  News
//
//  Created by Tomas Pecuch on 19/10/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let titleColor = Environment().configuration(.titleColor).hexStringToUIColor()
        titleLabel.textColor = titleColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
