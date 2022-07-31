//
//  WeatherClient.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Keys

struct UVClientRequest {
  let lat: Double
  let long: Double
}

struct UVClient {
  var fetchUVIndex: (UVClientRequest) -> Effect<Forecast, Failure>
  
  struct Failure: Error, Equatable {}
}

extension UVClient {
  static let live = UVClient(
    fetchUVIndex: { request in
      var request = URLRequest(url: URL(string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: [request.lat, request.long, SwiftUVKeys().openWeatherMapApiKey]))!)
      request.httpMethod = HTTPMethod.get.rawValue
      request.httpBody = try? JSONSerialization.data(withJSONObject: [:], options: [])
      
      return URLSession.shared.dataTaskPublisher(for: request.url!)
        .map { data, _ in data }
        .decode(type: Forecast.self, decoder: JSONDecoder())
        .mapError { _ in Failure() }
        .eraseToEffect()
    }
  )
}

#if DEBUG
extension UVClient {
  static let mock = Self(
    fetchUVIndex: { _ in
        Effect(value: Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5))
    }
  )
}
#endif
