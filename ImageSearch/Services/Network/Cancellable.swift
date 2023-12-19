//
//  Cancellable.swift
//  CryptocurrencyInfo
//
//  Created by Denis Simon on 11/18/2023.
//

import Foundation

protocol NetworkCancellable {
    func cancel()
}

extension URLSessionDataTask: NetworkCancellable {}

protocol Cancellable {
    var isCancelled: Bool { get set }
    func cancel()
}

class NetworkTask: Cancellable {
    var task: NetworkCancellable?
    var isCancelled = false
    
    func cancel() {
        task?.cancel()
        isCancelled = true
    }
}

