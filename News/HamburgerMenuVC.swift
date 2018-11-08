//
//  HamburgerMenuVC.swift
//  News
//
//  Created by Tomas Pecuch on 08/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import NavigationDrawer

class HamburgerMenuVC: UIViewController {

    var interactor:Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
