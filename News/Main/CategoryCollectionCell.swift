//
//  CategoryCollectionCell.swift
//  News
//
//  Created by Tomas Pecuch on 09/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var chosenIndicatorView: UIView!
    
    var isChosen: Bool = false
    
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
}
