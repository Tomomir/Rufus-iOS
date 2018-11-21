//
//  StaticPageVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class StaticPageVC: UIViewController, AcceptButtonDelegate, ReloadButtonDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBarBlurColorView: UIView!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: StaticPageData? = nil
    var tableData = [StaticPageData]()
    var loadingFailed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.loadStaticPages()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadingFailed {
            return 1
        } else {
            return tableData.count == 0 ? 0 : tableData.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // only shows reload button when loading failed
        if loadingFailed == true {
            let reloadButtonCell = tableView.dequeueReusableCell(withIdentifier: "ReloadButtonCell", for: indexPath) as! ReloadButtonCell
            reloadButtonCell.delegate = self
            return reloadButtonCell
        }
        
        if indexPath.row == tableData.count {
            let acceptButtonCell = tableView.dequeueReusableCell(withIdentifier: "AcceptButtonCell", for: indexPath) as! AcceptButtonCell
            acceptButtonCell.delegate = self
            return acceptButtonCell
        }
        
        let pageCell = tableView.dequeueReusableCell(withIdentifier: "StaticPageCell", for: indexPath) as! StaticPageCell
        pageCell.setData(pageData: tableData[indexPath.row])
        return pageCell
    }
    
    // MARK: - AcceptButtonDelegate
    
    /// saves acceptance of the static pages and presents the main screen
    func acceptButtonPressed() {
        //TODO: mark page as accepted
        if let userID = Auth.auth().currentUser?.uid {
            API.shared.saveStaticPageAcceptance(userID: userID)
            navigationController?.popToRootViewController(animated: true)
        } else {
            // TODO: handle error here
        }
    }
    
    // MARK: - ReloadButonDelegate
    
    /// reloads data when reload button is pressed
    func reloadButtonPressed() {
        self.loadStaticPages()
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
    }
    
    /// loads text of all static pages from Firebase 
    func loadStaticPages() {
        // shows loading indicator and hides tableview
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = ""
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 10.0)
        self.tableView.isHidden = true //hides table so you only see loading indicatior
        
        API.shared.getFullStaticPageDict { [weak self] (result) in
            hud.dismiss()
            self?.tableView.isHidden = false
            switch result {
            case .failure(let error):
                self?.loadingFailed = true
                print(error)
            case .success(let pageData):
                self?.loadingFailed = false
                self?.tableData = pageData
            }
            self?.tableView.reloadData()
        }
    }

}
