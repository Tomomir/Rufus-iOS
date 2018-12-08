//
//  ImageManager.swift
//  News
//
//  Created by Tomas Pecuch on 05/12/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation
import UIKit

class ImageManager {
    
    // singleton
    static var shared = ImageManager()

    
    /// saves image to the document directory
    ///
    /// - Parameters:
    ///   - image: image to save
    ///   - key: key of the article image belongs to
    /// - Returns: returns true if success false otherwise
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
    
    
    /// loads image from document directory
    ///
    /// - Parameter key: key of the article image belong to
    /// - Returns: returns image or nil if not found
    func getSavedImage(key: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(key).path)
        }
        return nil
    }
    
    
    /// deletes saved image from document directory
    ///
    /// - Parameter key: key of the article image belongs to
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
    
    
    /// download the image from given URL
    ///
    /// - Parameters:
    ///   - url: URL of the image
    ///   - completion: completion called after load is finished
    func imageDownloaded(from url: URL, completion: ((UIImage?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion?(nil)
                    return
                }
            DispatchQueue.main.async() {
                completion?(image)
            }
            }.resume()
    }
    
    
    /// loads the image from given url in string format
    ///
    /// - Parameters:
    ///   - link: url in string format
    ///   - completion: completion called after load is finished
    func imageDownloaded(from link: String, completion: ((UIImage?) -> Void)?) {
        guard let url = URL(string: link)
        else {
            completion?(nil)
            return
        }
        imageDownloaded(from: url, completion: completion)
    }
}
