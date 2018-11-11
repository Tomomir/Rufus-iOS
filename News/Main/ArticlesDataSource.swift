//
//  ArticlesDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 10/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

struct ArticleDataStruct {
    let author: String
    let category: String
    let featured: Bool
    let publishTime: Date
    let status: String
    let title: String
    let subtitle: String
    let text: String
}

import Foundation

class ArticlesDataSource {
    
    static var shared = ArticlesDataSource()
    
    var allArticles = [ArticleDataStruct]()
    var articlesToShow = [ArticleDataStruct]()
}
