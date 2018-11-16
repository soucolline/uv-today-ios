//
//  UVService.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Alamofire

class UVService {
  
  typealias SuccessCallback = (Forecast) -> Void
  typealias ErrorCallback = (Error) -> Void
  
  func getUVIndex(from location: Location, success: @escaping SuccessCallback, failure: @escaping ErrorCallback) {
    let url = K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: ["cc3256542b7071cba719d7ccd2b03c39", location.latitude, location.longitude])
    
    Alamofire.request(url).validate().responseJSON { response in
      do {
        guard let data = response.data else {
          failure(UVError.noData)
          return
        }
        
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        success(forecast)
      } catch let error {
        failure(error)
      }
    }
  }
  
}
