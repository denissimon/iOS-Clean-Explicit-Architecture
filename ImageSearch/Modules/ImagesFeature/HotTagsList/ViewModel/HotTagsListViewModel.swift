//
//  TagsListViewModel.swift
//  ImageSearch
//
//  Created by Denis Simon on 04/11/2020.
//

import Foundation

enum SegmentType {
    case week
    case allTimes
}

class HotTagsListViewModel {
    
    let networkService: NetworkService
    let didSelect: Event<ImageQuery>
    
    var dataForWeekFlickrTags = [Tag]()
    
    var selectedSegment: SegmentType = .week
    
    private(set) var data = [Tag]() {
        didSet {
            self.updateData.trigger(self.data)
        }
    }
    
    // Delegates
    let updateData = Event<[Tag]>()
    let showToast = Event<String>()
    
    // Bindings
    let activityIndicatorVisibility = Observable<Bool>(false)
    
    init(networkService: NetworkService, didSelect: Event<ImageQuery>) {
        self.networkService = networkService
        self.didSelect = didSelect
    }
    
    func getDataSource() -> TagsDataSource {
        return TagsDataSource(with: data)
    }
    
    func showErrorToast(_ msg: String = "") {
        if msg.isEmpty {
            self.showToast.trigger("Network error")
        } else {
            self.showToast.trigger(msg)
        }
        self.activityIndicatorVisibility.value = false
    }
    
    func getFlickrHotTags() {
        self.activityIndicatorVisibility.value = true
        
        let endpoint = FlickrAPI.getHotTagsList
        
        networkService.requestEndpoint(endpoint, type: Tags.self) { [weak self] (result) in
            guard let self = self else { return }
            
            var allHotFlickrTags = [Tag]()
            
            switch result {
            case .done(let tags):
                if tags.stat == "ok" {
                    allHotFlickrTags = self.composeFlickrHotTags(type: .week, weekHotTags: tags.hottags.tag)
                }
                self.dataForWeekFlickrTags = allHotFlickrTags
                self.activityIndicatorVisibility.value = false
            case .error(let error):
                if error.0 != nil {
                    self.showErrorToast(error.0!.localizedDescription)
                } else {
                    self.showErrorToast()
                }
            }
            
            if self.selectedSegment == .week {
                self.data = allHotFlickrTags
            }
        }
    }
    
    private func composeFlickrHotTags(type: SegmentType, weekHotTags: [Tag]? = nil) -> [Tag] {
        let allTimesHotTagsStr = ["sunset","beach","water","sky","flower","nature","blue","night","white","tree","green","flowers","portrait","art","light","snow","dog","sun","clouds","cat","park","winter","landscape","street","summer","sea","city","trees","yellow","lake","christmas","people","bridge","family","bird","river","pink","house","car","food","bw","old","macro","music","new","moon","orange","garden","blackandwhite","home"]
        var allTimesHotTags = [Tag]()
        for tag in allTimesHotTagsStr {
            allTimesHotTags.append(Tag(name: tag))
        }
        
        switch type {
        case .week:
            if weekHotTags != nil {
                return weekHotTags!
            } else {
                return [Tag]()
            }
        case .allTimes:
            return allTimesHotTags
        }
    }
    
    func onSelectedSegmentChange(_ index: Int) {
        if index == 0 {
            selectedSegment = .week
            data = dataForWeekFlickrTags
        } else if index == 1 {
            selectedSegment = .allTimes
            data = composeFlickrHotTags(type: .allTimes)
        }
    }
}