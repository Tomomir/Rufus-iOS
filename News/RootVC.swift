//
//  RootVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class RootVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // initiate and push main view controller
        let vc = storyboard?.instantiateViewController(withIdentifier: "MainVC") as? MainVC
        addChildVC(vc!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
