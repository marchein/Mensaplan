//
//  UIImageView+Download.swift
//  Mensaplan
//
//  Created by Marc Hein on 22.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func loadImage(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        
        if let cacheImage = MensaplanApp.imageCache.object(forKey: link as AnyObject) as? UIImage {
            print("loading image from cache: \(link)")
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: link) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Couldn't download image: ", error)
                self.loadImage(from: link)
                return
            }
            
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            MensaplanApp.imageCache.setObject(image, forKey: link as AnyObject)
            
            DispatchQueue.main.async {
                print("downloading image: \(link)")
                self.image = image
            }
        }.resume()

    }
}
