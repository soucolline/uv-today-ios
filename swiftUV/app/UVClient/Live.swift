//
//  Live.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import Foundation
import ComposableArchitecture
import CoreLocation
import Keys

extension UVClient {
  static let live = UVClient(
    fetchUVIndex: { request in
      var request = URLRequest(url: URL(string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: [request.lat, request.long, SwiftUVKeys().openWeatherMapApiKey]))!)
      request.httpMethod = "GET"
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
