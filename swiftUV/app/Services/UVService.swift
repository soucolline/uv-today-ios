//
//  UVService.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import ZLogger
import Keys

protocol UVService {
  func getUVIndex(from location: Location, completion: @escaping (Result<Forecast, UVError>) -> Void)
}

class UVServiceImpl: UVService {

  private let apiExecutor: APIWorker
  private let urlFactory: URLFactory
  
  init(with apiExecutor: APIWorker, urlFactory: URLFactory) {
    self.apiExecutor = apiExecutor
    self.urlFactory = urlFactory
  }
  
  func getUVIndex(from location: Location, completion: @escaping (Result<Forecast, UVError>) -> Void) {
    let url = self.urlFactory.createUVURL(lat: location.latitude, lon: location.longitude)

    ZLogger.info(message: "\(url)")
    
    self.apiExecutor.request(for: Forecast.self, at: url, method: .get, parameters: [:], completion: { result in
      switch result {
      case .success(let forecast):
        ZLogger.info(message: "Retrieved index \(forecast.value)")
        completion(.success(forecast))
      case .failure(let error):
        ZLogger.error(message: error.localizedDescription)
        completion(.failure(error))
      }
    })
  }
}
