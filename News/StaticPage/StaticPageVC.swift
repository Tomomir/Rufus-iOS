//
//  StaticPageVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class StaticPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBarBlurColorView: UIView!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var navigationBackButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var data: StaticPageData? = nil
    var tableData = [StaticPageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        self.setupTableView()
        self.loadStaticPages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.shared.currentVC = self
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pageCell = tableView.dequeueReusableCell(withIdentifier: "StaticPageCell", for: indexPath) as! StaticPageCell
        pageCell.setData(pageData: tableData[indexPath.row])
        return pageCell
    }
    
    // MARK: - Other

    /// setups basic layout of the tableview
    func setupTableView() {
        
        // moves tableview starting position so it doesnt start under navigation bar
        if let navBar = navigationView {
            tableView.contentInset = UIEdgeInsets(top: navBar.bounds.origin.y + navBar.bounds.size.height + 10, left: 0, bottom: 0, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
        
        // allows us to have different cell heights without defiing exact height for every cell
        tableView.estimatedRowHeight = 299
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    /// sets values from config file
    func configurate() {
        if let alpha = Environment().configuration(.navigationBarBlurAlpha).CGFloatValue() {
            self.navigationBarBlurColorView.alpha = alpha
        }
        let color = Environment().configuration(.navigationBarColor).hexStringToUIColor()
        self.navigationBarBlurColorView.backgroundColor = color
        
        if let useBlur = Environment().configuration(.navigationBarUseBlur).BoolValue() {
            self.navigationBlurView.isHidden = !useBlur
        }
        errorLabel.font = UIFont().configFontOfSize(size: errorLabel.font.pointSize)
        errorLabel.textColor = Environment().configuration(.warningTextColor).hexStringToUIColor()
    }
    
    /// loads text of all static pages from Firebase 
    func loadStaticPages() {
        // shows loading indicator
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = ""
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 7.0)
        self.tableView.isHidden = true //hides table so you only see loading indicatior
        UIView.animateKeyframes(withDuration: 0.3, delay: 8, options: [], animations: { [weak self] in
            self?.errorLabel.alpha = 1
        }, completion: nil)
        
        API.shared.getFullStaticPageDict { [weak self] (result) in
            hud.dismiss()
            self?.errorLabel.isHidden = true
            self?.tableView.isHidden = false
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pageData):
                self?.tableData = pageData
            }
            self?.tableView.reloadData()
        }
    }

}
