import Foundation

class DefaultTagRepository: TagRepository {
    
    let apiInteractor: APIInteractor
    
    init(apiInteractor: APIInteractor) {
        self.apiInteractor = apiInteractor
    }
    
    func getHotTags() async -> Result<TagsType, CustomError> {
        let endpoint = FlickrAPI.getHotTags()
        do {
            let tags = try await apiInteractor.request(endpoint, type: Tags.self)
            if tags.stat != "ok" {
                return .failure(CustomError.server())
            }
            return .success(tags)
        } catch {
            if error is CustomError {
                return .failure(error as! CustomError)
            }
            return .failure(CustomError.unexpected(error))
        }
    }
}
