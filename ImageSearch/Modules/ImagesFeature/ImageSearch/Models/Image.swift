//
//  Image.swift
//  ImageSearch
//
//  Created by Denis Simon on 02/19/2020.
//

import Foundation

class Image {
    var thumbnail: ImageWrapper?
    var largeImage: ImageWrapper?
    let imageID: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
    
    init (imageID: String, farm: Int, server: String, secret: String, title: String) {
        self.imageID = imageID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    func getImageURL(_ size: String = "m") -> URL? {
        if let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(imageID)_\(secret)_\(size).jpg") {
          return url
        }
        return nil
    }
}