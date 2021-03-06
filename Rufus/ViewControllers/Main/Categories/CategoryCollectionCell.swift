//
//  CategoryCollectionCell.swift
//  News
//
//  Created by Tomas Pecuch on 09/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellContainerViewHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var chosenIndicatorView: UIView!
    
    var isChosen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configurate()
        self.cellContainerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    /// sets UI of the category cell to given state
    ///
    /// - Parameters:
    ///   - chosen: boolean wheter cell is chosen
    ///   - animated: boolean wheter it should be animated
    func setChosen(chosen: Bool, animated: Bool) {
        switch chosen {
        case true:
            if animated {
                UIView.animate(withDuration: 0.2) {
                    self.chosenIndicatorView.alpha = 1
                }
            } else {
                self.chosenIndicatorView.alpha = 1
            }
            
        case false:
            if animated {
                UIView.animate(withDuration: 0.2) {
                    self.chosenIndicatorView.alpha = 0
                }
            } else {
                self.chosenIndicatorView.alpha = 0
            }
        }
        
        isChosen = chosen
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        let titleColor = Environment().configuration(.titleColor).hexStringToUIColor()
        self.nameLabel.textColor = titleColor
        self.chosenIndicatorView.backgroundColor = titleColor
    }
}
