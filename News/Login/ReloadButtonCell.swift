//
//  ReloadButtonCell.swift
//  News
//
//  Created by Tomas Pecuch on 21/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

protocol ReloadButtonDelegate: class {
    func reloadButtonPressed()
}

class ReloadButtonCell: UITableViewCell {

    @IBOutlet weak var reloadButton: UIButton!
    
    weak var delegate: ReloadButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    
    /// called when reload button is pressed
    @IBAction func reloadButtonPressed(_ sender: Any) {
        delegate?.reloadButtonPressed()
    }
}
