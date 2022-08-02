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
import CoreLocation

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

extension UVClient {
  static let live = UVClient(
    fetchUVIndex: { request in
      var request = URLRequest(url: URL(string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: [request.lat, request.long, SwiftUVKeys().openWeatherMapApiKey]))!)
      request.httpMethod = HTTPMethod.get.rawValue
      request.httpBody = try? JSONSerialization.data(withJSONObject: [:], options: [])
      
      return URLSession.shared.dataTaskPublisher(for: request.url!)
        .map { data, _ in data }
        .decode(type: Forecast.self, decoder: JSONDecoder())
        .mapError { error in Failure(errorDescription: error.localizedDescription) }
        .eraseToEffect()
    },
    fetchCityName: { location in
      Effect.future { callback in
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
          guard error == nil else {
            callback(.failure(Failure(errorDescription: error!.localizedDescription)))
            return
          }
          
          let cityName = placemarks?.first?.locality ?? "Unknown"
          callback(.success(cityName))
        }
      }
    }
  )
}

#if DEBUG
extension UVClient {
  static let mock = Self(
    fetchUVIndex: { _ in
      Effect(value: Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5))
    },
    fetchCityName: { _ in
      Effect(value: "Gueugnon")
    }
  )
}
#endif
