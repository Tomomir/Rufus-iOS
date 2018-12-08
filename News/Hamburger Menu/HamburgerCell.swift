//
//  HamburgerCell.swift
//  News
//
//  Created by Tomas Pecuch on 08/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class HamburgerCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cellTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    /// marks the cell as selected or deselected
    ///
    /// - Parameter selected: boolean which determines if the cell should be selected or not
    func markSelected(selected: Bool) {
        if selected {
            cellTextLabel.textColor = Environment().configuration(.hamburgerMenuColor).hexStringToUIColor()
            iconImageView.tintColor = Environment().configuration(.hamburgerMenuColor).hexStringToUIColor()
        } else {
            cellTextLabel.textColor = UIColor.black
            iconImageView.tintColor = UIColor.black
        }
    }
}
