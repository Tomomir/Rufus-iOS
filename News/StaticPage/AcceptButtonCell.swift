//
//  AcceptButtonCell.swift
//  News
//
//  Created by Tomas Pecuch on 21/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

protocol AcceptButtonDelegate: class {
    func acceptButtonPressed()
}


/// table cell which show accept button
class AcceptButtonCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    
    weak var delegate: AcceptButtonDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configurate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    /// called when accept button is pressed
    ///
    /// - Parameter sender: button which was pressed
    @IBAction func acceptButtonPressed(_ sender: Any) {
        delegate?.acceptButtonPressed()
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        let buttonColor = Environment().configuration(.buttonColor).hexStringToUIColor()
        acceptButton.backgroundColor = buttonColor
    }
}
