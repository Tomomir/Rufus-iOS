//
//  StaticPageCell.swift
//  News
//
//  Created by Tomas Pecuch on 21/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit


/// cell which is showing data of single static page
class StaticPageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var contentTextLabel: UILabel!
    
    var data: StaticPageData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configurate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        if let titleFontSize = Environment().configuration(.titleFontSize).CGFloatValue() {
            titleLabel.font = titleLabel.font.withSize(titleFontSize)
        }
        if let subtitleFontSize = Environment().configuration(.subtitleFontSize).CGFloatValue() {
            subtitleLabel.font = subtitleLabel.font.withSize(subtitleFontSize)
        }
        if let textFontSize = Environment().configuration(.textFontSize).CGFloatValue() {
            contentTextLabel.font = contentTextLabel.font.withSize(textFontSize)
        }
        titleLabel.font = UIFont().configFontOfSize(size: titleLabel.font.pointSize)
        subtitleLabel.font = UIFont().configFontOfSize(size: subtitleLabel.font.pointSize)
        contentTextLabel.font = UIFont().configFontOfSize(size: contentTextLabel.font.pointSize)
        
        titleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        subtitleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        contentTextLabel.textColor = Environment().configuration(.textColor).hexStringToUIColor()
    }
    
    /// setup cell using static page data
    ///
    /// - Parameter pageData: data to show
    func setData(pageData: StaticPageData) {
        data = pageData
        titleLabel.text = pageData.title
        subtitleLabel.text = pageData.subTitle
        contentTextLabel.attributedText = pageData.text.htmlToAttributedString
    }

}
