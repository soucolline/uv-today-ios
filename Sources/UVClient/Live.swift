//
//  Live.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import CoreLocation
import Models

extension UVClient {
  public static let live = UVClient(
    fetchUVIndex: { request in
      let url = URL(
        string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: [request.lat, request.long, "73c6746593df6d9b6d412026b3db9239"]))!
      do {
        let (response, _) = try await URLSession.shared.data(from: url)
        let forectast = try JSONDecoder().decode(Forecast.self, from: response)
        return forectast
      } catch {
        throw error
      }
    },
    fetchCityName: { location in
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
  )
}
