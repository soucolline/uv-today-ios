//
//  WeatherClient.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import CoreLocation
import Models
import WeatherKit

public protocol UVClient: Sendable {
  func fetchUVIndex(request: UVClientRequest) async throws -> Index
  func fetchCityName(location: Models.Location) async throws -> String
  func fetchWeatherKitAttribution() async throws -> AttributionResponse
}

public final class UVClientImpl: UVClient {
  public func fetchUVIndex(request: UVClientRequest) async throws -> Index {
    let clLocation = CLLocation(latitude: request.lat, longitude: request.long)
    let weather = try? await WeatherService.shared.weather(for: clLocation, including: .current)
    
    guard let weather else { throw UVError.noWeatherAvailable }
    
    return weather.uvIndex.value
  }
  
  public func fetchCityName(location: Location) async throws -> String {
    try await withUnsafeThrowingContinuation { continuation in
      let geocoder = CLGeocoder()
      let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
      geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
        guard error == nil else {
          continuation.resume(throwing: error!)
          return
        }
        
        let cityName = placemarks?.first?.locality ?? "Unknown"
        continuation.resume(returning: cityName)
      }
    }
  }
  
  public func fetchWeatherKitAttribution() async throws -> AttributionResponse {
    do {
      let attribution = try await WeatherService.shared.attribution
      
      return AttributionResponse(logo: attribution.combinedMarkDarkURL, link: attribution.legalPageURL)
    } catch {
      throw UVError.noAttributionAvailable
    }
  }
}
