//
//  UVService.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import ZLogger
import Combine
import Resolver

protocol UVService {
  func getUVIndex(from location: Location) -> AnyPublisher<Index, UVError>
}

class UVServiceImpl: UVService {

  private let apiExecutor: APIWorker
  private let urlFactory: URLFactory
  
  init(apiExecutor: APIWorker, urlFactory: URLFactory) {
    self.apiExecutor = apiExecutor
    self.urlFactory = urlFactory
  }

  func getUVIndex(from location: Location) -> AnyPublisher<Index, UVError> {
    let url = self.urlFactory.createUVURL(lat: location.latitude, lon: location.longitude)

    ZLogger.info(message: "\(url)")

    return self.apiExecutor.request(for: Forecast.self, at: url, method: .get, parameters: [:])
      .map { forecast in
        Int(forecast.value.rounded())
      }
      .eraseToAnyPublisher()
  }
}
