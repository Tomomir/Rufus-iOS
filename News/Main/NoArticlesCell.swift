//
//  NoArticlesCell.swift
//  News
//
//  Created by Tomas Pecuch on 07/12/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class NoArticlesCell: UITableViewCell {

    @IBOutlet weak var noArticlesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noArticlesLabel.font = UIFont().configFontOfSize(size: noArticlesLabel.font.pointSize)
        noArticlesLabel.textColor = Environment().configuration(.warningTextColor).hexStringToUIColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
