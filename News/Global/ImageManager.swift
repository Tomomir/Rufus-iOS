//
//  ImageManager.swift
//  News
//
//  Created by Tomas Pecuch on 05/12/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import Foundation
import UIKit

class ImageManager {
    
    static var shared = ImageManager()

    func saveImageToDocumentsUnderKey(image: UIImage?, key: String) -> Bool {
        if image == nil { return false }
        guard let data = image!.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(key).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(key: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(key).path)
        }
        return nil
    }
    
    func removeSavedImage(key: String) {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try "".write(to: directory.appendingPathComponent("\(key).png")!, atomically: true, encoding: .utf8)
            return
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func imageDownloaded(from url: URL, completition: ((UIImage?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completition?(nil)
                    return
                }
            DispatchQueue.main.async() {
                completition?(image)
            }
            }.resume()
    }
    
    func imageDownloaded(from link: String, completition: ((UIImage?) -> Void)?) {
        guard let url = URL(string: link)
        else {
            completition?(nil)
            return
        }
        imageDownloaded(from: url, completition: completition)
    }
}
