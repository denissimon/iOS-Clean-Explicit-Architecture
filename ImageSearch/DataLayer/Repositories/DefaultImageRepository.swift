//
//  DefaultImageRepository.swift
//  ImageSearch
//
//  Created by Denis Simon on 12/25/2023.
//

import Foundation

class DefaultImageRepository: ImageRepository {
    
    let apiInteractor: APIInteractor
    let imageDBInteractor: ImageDBInteractor
    
    init(apiInteractor: APIInteractor, imageDBInteractor: ImageDBInteractor) {
        self.apiInteractor = apiInteractor
        self.imageDBInteractor = imageDBInteractor
    }
    
    private func searchImages(_ imageQuery: ImageQuery, completionHandler: @escaping (ImagesDataResult) -> Void) -> Cancellable? {
        let endpoint = FlickrAPI.search(imageQuery)
        let task = RepositoryTask()
        task.networkTask = apiInteractor.requestEndpoint(endpoint) { result in
            guard !task.isCancelled else { return }
            completionHandler(result)
        }
        return task
    }
    
    // A pure transformation of the data (a pure function within the impure context)
    private func prepareImages(_ imagesData: Data, completionHandler: @escaping (Images?) -> Void) {
        do {
            guard
                !imagesData.isEmpty,
                let resultsDictionary = try JSONSerialization.jsonObject(with: imagesData) as? [String: AnyObject],
                let stat = resultsDictionary["stat"] as? String
                else {
                    completionHandler(nil)
                    return
            }

            if stat != "ok" {
                completionHandler(nil)
                return
            }
            
            guard
                let container = resultsDictionary["photos"] as? [String: AnyObject],
                let photos = container["photo"] as? [[String: AnyObject]]
                else {
                    completionHandler(nil)
                    return
            }
            
            let imagesFound: [Image] = photos.compactMap { photoObject in
                guard
                    let imageID = photoObject["id"] as? String,
                    let farm = photoObject["farm"] as? Int,
                    let server = photoObject["server"] as? String,
                    let secret = photoObject["secret"] as? String,
                    let title = photoObject["title"] as? String
                    else {
                        return nil
                }

                return Image(imageID: imageID, farm: farm, server: server, secret: secret, title: title)
            }
            
            if imagesFound.isEmpty {
                completionHandler(nil)
            } else {
                let images = Images(data: imagesFound)
                completionHandler(images)
            }
        } catch {
            completionHandler(nil)
        }
    }
    
    private func getImage(url: URL, completionHandler: @escaping (Data?) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        task.networkTask = apiInteractor.fetchFile(url: url) { result in
            guard !task.isCancelled else { return }
            completionHandler(result)
        }
        return task
    }
    
    private func saveImage(_ image: Image, searchId: String, sortId: Int, completionHandler: @escaping (Bool?) -> Void) {
        imageDBInteractor.saveImage(image, searchId: searchId, sortId: sortId, type: Image.self) { result in
            completionHandler(result)
        }
    }
    
    private func getImages(searchId: String, completionHandler: @escaping ([Image]?) -> Void) {
        imageDBInteractor.getImages(searchId: searchId, type: Image.self) { result in
            completionHandler(result)
        }
    }
    
    private func checkImagesAreCached(searchId: String, completionHandler: @escaping (Bool?) -> Void) {
        imageDBInteractor.checkImagesAreCached(searchId: searchId) { result in
            completionHandler(result)
        }
    }
    
    // MARK: - async API methods
    
    func searchImages(_ imageQuery: ImageQuery) async -> ImagesDataResult {
        await withCheckedContinuation { continuation in
            let _ = searchImages(imageQuery) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func prepareImages(_ imageData: Data) async -> Images? {
        await withCheckedContinuation { continuation in
            prepareImages(imageData) { result in
                continuation.resume(returning: result)
            }
        }
    }
     
    func getImage(url: URL) async -> Data? {
         await withCheckedContinuation { continuation in
             let _ = getImage(url: url) { result in
                 continuation.resume(returning: result)
             }
         }
    }
    
    // MARK: - async DB methods
    
    func saveImage(_ image: Image, searchId: String, sortId: Int) async -> Bool? {
        await withCheckedContinuation { continuation in
            saveImage(image, searchId: searchId, sortId: sortId) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func getImages(searchId: String) async -> [Image]? {
        await withCheckedContinuation { continuation in
            getImages(searchId: searchId) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func checkImagesAreCached(searchId: String) async -> Bool? {
        await withCheckedContinuation { continuation in
            checkImagesAreCached(searchId: searchId) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func deleteAllImages() async {
        imageDBInteractor.deleteAllImages()
    }
}
