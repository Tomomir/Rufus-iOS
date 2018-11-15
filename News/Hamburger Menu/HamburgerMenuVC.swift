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
    case savedArticles
    case readArticles
    case logout
    case cellsCount
}

class HamburgerMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    var interactor:Interactor? = nil
    var mainVC: MainVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            if let imageUrl = user.photoURL {
                profileImageView.loadFromURL(photoUrl: imageUrl.absoluteString)
            }
        }
        // Do any additional setup after loading the view.
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
        case HamburgerTableViewCellType.purchasedArticles.rawValue:
            cell.cellTextLabel.text = "Purchased"
        case HamburgerTableViewCellType.savedArticles.rawValue:
            cell.cellTextLabel.text = "Saved"
        case HamburgerTableViewCellType.readArticles.rawValue:
            cell.cellTextLabel.text = "Already Read"
        case HamburgerTableViewCellType.logout.rawValue:
            cell.cellTextLabel.text = "Logout"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case HamburgerTableViewCellType.allArticles.rawValue:
            break
        case HamburgerTableViewCellType.purchasedArticles.rawValue:
            break
        case HamburgerTableViewCellType.savedArticles.rawValue:
            break
        case HamburgerTableViewCellType.readArticles.rawValue:
            break
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
}
