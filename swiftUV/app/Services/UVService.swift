//
//  UVService.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import ZLogger

protocol UVService {
  func getUVIndex(from location: Location, completion: @escaping (Swift.Result<Forecast, Error>) -> Void)
}

class UVServiceImpl: UVService {

  private let apiExecutor: APIWorker
  
  init(with apiExecutor: APIWorker) {
    self.apiExecutor = apiExecutor
  }
  
  func getUVIndex(from location: Location, completion: @escaping (Swift.Result<Forecast, Error>) -> Void) {
    let url = URL(string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: ["cc3256542b7071cba719d7ccd2b03c39", location.latitude, location.longitude]))!
    
    self.apiExecutor.request(for: Forecast.self, at: url, method: .get, parameters: [:], completion: { result in
      switch result {
      case .success(let forecast):
        ZLogger.log(message: "Retrieved index \(forecast.currently.uvIndex)", event: .info)
        completion(.success(forecast))
      case .failure(let error):
        ZLogger.log(message: error.localizedDescription, event: .error)
        completion(.failure(error))
      }
    })
  }
}
