//
//  SharedKernel.swift
//  ImageSearch
//
//  Created by Denis Simon on 01/28/2024.
//

import Foundation

/* Note: Behavior classes should ideally contain pure functions without side effects.
Input: an entity / collection of entities, and, optionally, additional parameters
Output: a transformed entity / collection of entities, or a specified simple type such as URL? or Int
*/

// Delegate the behavior of Image entity
class ImageBehavior {
    
    static func getFlickrImageURL(_ image: Image, size: ImageSize) -> URL? {
        guard let flickrParams = image.flickr else { return nil }
        if let url = URL(string: "https://farm\(flickrParams.farm).staticflickr.com/\(flickrParams.server)/\(flickrParams.imageID)_\(flickrParams.secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }
    
    static func updateImage(_ image: Image, newWrapper: ImageWrapper?, for size: ImageSize) -> Image {
        let resultImage = image.deepCopy()
        switch size {
        case .thumbnail:
            resultImage.thumbnail = newWrapper
        case .big:
            resultImage.bigImage = newWrapper
        }
        return resultImage
    }
}
