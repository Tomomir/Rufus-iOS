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

class CategoryDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //singleton
    static var shared = CategoryDataSource()

    private var indexOfCellBeforeDragging = 0
    
    var categories = [CategoryData]()
    private var selectedCellIndex: Int = 0
    
    var collectionView: UICollectionView?
    var mainVC: MainVC?
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = categories[indexPath.row].name
        let width = UILabel.textWidth(font: UIFont.systemFont(ofSize: 17.0), text: text)
        return CGSize(width: width + 10, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // if selecting selected cell do nothing
        if indexPath.row == selectedCellIndex { return }
        
        let cellToSelect = collectionView.cellForItem(at: indexPath) as! CategoryCollectionCell
        if let cellToDeselect = collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? CategoryCollectionCell {
            cellToDeselect.setChosen(chosen: false, animated: true)

        }
        cellToSelect.setChosen(chosen: true, animated: true)
        
        mainVC?.selectCategoryAtIndex(newIndex: indexPath.row, oldIndex: selectedCellIndex)
        selectedCellIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let categoryCell = cell as? CategoryCollectionCell else { return }
        categoryCell.setChosen(chosen: selectedCellIndex == indexPath.row, animated: false)
    }
    
    // MARK: - Other
    
    func selectCategory(categoryKey: String) {
        for (index,category) in categories.enumerated() {
            if category.key == categoryKey {
                selectCategoryAtIndex(index: index)
            }
        }
    }
    
    func selectCategoryAtIndex(index: Int) {
        // if selecting selected cell do nothing
        if index == selectedCellIndex { return }
        
        if let cellToSelect = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? CategoryCollectionCell {
            cellToSelect.setChosen(chosen: true, animated: true)
        }
        if let cellToDeselect = collectionView?.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? CategoryCollectionCell {
            cellToDeselect.setChosen(chosen: false, animated: true)
        }
        
        selectedCellIndex = index
    }
    
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
        self.collectionView?.reloadData()
//        mainVC?.setCategoryPages(categories: sortedCategories)
    }
    
    func sortCategories(keysDict: [Int: Any]) {
        
        var sortedCategories = [CategoryData]()
        sortedCategories.append(CategoryData(key: "all", name: "All"))
        
        for (_,value) in keysDict.enumerated() {
            for category in categories {
                if let categoryKey = value.value as? String {
                    if categoryKey == category.key {
                        sortedCategories.append(category)
                    }
                }
            }
        }
        categories = sortedCategories
        self.collectionView?.reloadData()
    }
    
}
