//
//  CategoriesDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 09/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import Foundation
import UIKit

//structure that represents single category
struct CategoryData {
    let key: String
    let name: String
}

class CategoryDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //singleton
    static var shared = CategoryDataSource()

    private var indexOfCellBeforeDragging = 0
    
    private var categories = [CategoryData]()
    private var selectedCellIndex: Int = 0
    
    var collectionView: UICollectionView?
    
    // MARK: - UICollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
        cell.nameLabel.text = categories[indexPath.row].name
        cell.setChosen(chosen: selectedCellIndex == indexPath.row ? true : false, animated: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // if selecting selected cell do nothing
        if indexPath.row == selectedCellIndex { return }

        let cellToSelect = collectionView.cellForItem(at: indexPath) as! CategoryCollectionCell
        if let cellToDeselect = collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? CategoryCollectionCell {
            cellToDeselect.setChosen(chosen: false, animated: true)

        }
        cellToSelect.setChosen(chosen: true, animated: true)
        
        selectedCellIndex = indexPath.row
        ArticlesDataSource.shared.setCategory(categoryKey: categories[selectedCellIndex].key)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let categoryCell = cell as? CategoryCollectionCell else { return }
        if categoryCell.isChosen {
            if selectedCellIndex != indexPath.row {
                categoryCell.setChosen(chosen: false, animated: false)
            }
        }
    }
    
    // MARK: - Other
    
    
    /// Creates categories array from downloaded dictionary
    ///
    /// - Parameter categories: dictionary containing keys and name of the categories
    func setCategories(categories: [String: Any]) {
        self.categories.removeAll()

        for categoryKey in categories.keys {
            let key = categoryKey
            if let name = (categories[key] as! [String : String])["name"] {
                self.categories.append(CategoryData(key: key, name: name))
            }
        }
        self.collectionView?.reloadData()
    }
    
    
    /// Sorts categories
    ///
    /// - Parameter keysArray: array of key according to which it sorts categories
    func sortCategories(keysArray: [String]) {
        var sortedCategories = [CategoryData]()
        sortedCategories.append(CategoryData(key: "all", name: "All"))
        
        for key in keysArray {
            for category in categories {
                if key == category.key {
                    sortedCategories.append(category)
                }
            }
        }
        categories = sortedCategories
    }
    
    
}
