//
//  HamburgerMenuVC.swift
//  News
//
//  Created by Tomas Pecuch on 08/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import NavigationDrawer
import Firebase

enum HamburgerTableViewCellType: Int {
    case allArticles
    case purchasedArticles
    case readArticles
    case savedArticles
    case staticPages
    case logout
    case cellsCount
}

class HamburgerMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    var interactor:Interactor? = nil
    var mainVC: MainVC? = nil
    var selectedCellIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        
        
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            if let imageUrl = user.photoURL {
                profileImageView.loadFromURL(photoUrl: imageUrl.absoluteString)
            }
        }
        self.setSelectedCellIndex()
    }
    
    //Handle Gesture
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableviewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HamburgerTableViewCellType.cellsCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HamburgerCell", for: indexPath) as! HamburgerCell

        switch indexPath.row {
        case HamburgerTableViewCellType.allArticles.rawValue:
            cell.cellTextLabel.text = "All"
            cell.iconImageView.image = UIImage(named: "round_all_inbox_black_24pt")
        case HamburgerTableViewCellType.purchasedArticles.rawValue:
            cell.cellTextLabel.text = "Purchased"
            cell.iconImageView.image = UIImage(named: "round_monetization_on_black_24pt")
        case HamburgerTableViewCellType.savedArticles.rawValue:
            cell.cellTextLabel.text = "Saved"
            cell.iconImageView.image = UIImage(named: "round_save_alt_black_24pt")
        case HamburgerTableViewCellType.readArticles.rawValue:
            cell.cellTextLabel.text = "Already Read"
            cell.iconImageView.image = UIImage(named: "round_history_black_24pt")
        case HamburgerTableViewCellType.staticPages.rawValue:
            cell.cellTextLabel.text = "Terms of use"
            cell.iconImageView.image = UIImage(named: "round_description_black_24pt")
        case HamburgerTableViewCellType.logout.rawValue:
            cell.cellTextLabel.text = "Logout"
            cell.iconImageView.image = UIImage(named: "baseline_exit_to_app_black_24pt")
        default:
            break
        }

        if selectedCellIndex == indexPath.row {
            cell.markSelected(selected: true)
        } else {
            cell.markSelected(selected: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HamburgerCell {
            cell.markSelected(selected: true)
        }
        if let cellToDeselect = tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as? HamburgerCell {
            cellToDeselect.markSelected(selected: false)
        }
        if indexPath.row <= HamburgerTableViewCellType.readArticles.rawValue {
            selectedCellIndex = indexPath.row
        }
        
        
        switch indexPath.row {
        case HamburgerTableViewCellType.allArticles.rawValue:
            self.dismiss(animated: true) {
                self.mainVC?.setPagesMode(mode: .all)
            }
        case HamburgerTableViewCellType.purchasedArticles.rawValue:
            self.dismiss(animated: true) {
                self.mainVC?.setPagesMode(mode: .paid)
            }
        case HamburgerTableViewCellType.savedArticles.rawValue:
            self.dismiss(animated: true) {
                let savedVC = self.storyboard?.instantiateViewController(withIdentifier: "SavedArticlesVC") as! SavedArticlesVC
                
                self.mainVC!.navigationController?.pushViewController(savedVC, animated: true)
            }
        case HamburgerTableViewCellType.readArticles.rawValue:
            self.dismiss(animated: true) {
                self.mainVC?.setPagesMode(mode: .read)
            }
        case HamburgerTableViewCellType.staticPages.rawValue:
            self.dismiss(animated: true) {
                let staticPageVC = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
                self.mainVC!.navigationController?.pushViewController(staticPageVC, animated: true)
            }
        case HamburgerTableViewCellType.logout.rawValue:
            API.shared.logout()
            dismiss(animated: true) {
                if let mainController = self.mainVC {
                    mainController.pushLoginVC()
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        let topBackgroundColor = Environment().configuration(.hamburgerMenuColor).hexStringToUIColor()
        topBackgroundView.backgroundColor = topBackgroundColor
        emailLabel.font = UIFont().configFontOfSize(size: emailLabel.font.pointSize)
    }
    
    func setSelectedCellIndex() {
        if let mainController = mainVC {
            switch mainController.mode {
            case .all:
                selectedCellIndex = HamburgerTableViewCellType.allArticles.rawValue
            case .paid:
                selectedCellIndex = HamburgerTableViewCellType.purchasedArticles.rawValue
            case .read:
                selectedCellIndex = HamburgerTableViewCellType.readArticles.rawValue
            default:
                break
            }
        }
    }
}
