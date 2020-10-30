//
//  NetworkSession.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 28/06/2019.
//  Copyright © 2019 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Combine

protocol NetworkSession {
  func loadData(from url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {
  func loadData(from url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    dataTaskPublisher(for: url).eraseToAnyPublisher()
  }
}
