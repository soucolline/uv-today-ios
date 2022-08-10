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
  var fetchUVIndex: @Sendable (UVClientRequest) async throws -> Forecast
  var fetchCityName: @Sendable (Location) async throws -> String
  
  struct Failure: Error, Equatable {
    let errorDescription: String
  }
}
