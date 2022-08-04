//
//  WeatherClient.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture

struct UVClientRequest {
  let lat: Double
  let long: Double
}

struct UVClient {
  var fetchUVIndex: (UVClientRequest) -> Effect<Forecast, Failure>
  var fetchCityName: (Location) -> Effect<String, Failure>
  
  struct Failure: Error, Equatable {
    let errorDescription: String
  }
}
