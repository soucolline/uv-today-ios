//
//  WeatherClient.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import Models

public struct UVClientRequest {
  public let lat: Double
  public let long: Double
  
  public init(lat: Double, long: Double) {
    self.lat = lat
    self.long = long
  }
}

public struct UVClient {
  public var fetchUVIndex: @Sendable (UVClientRequest) async throws -> Index
  public var fetchCityName: @Sendable (Models.Location) async throws -> String
  public var fetchWeatherKitAttribution: @Sendable () async throws -> AttributionResponse
  
  struct Failure: Error, Equatable {
    let errorDescription: String
  }
}
