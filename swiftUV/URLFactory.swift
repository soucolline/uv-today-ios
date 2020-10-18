//
//  URLFactory.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 18/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation

#warning("Write tests")
final class URLFactory {

  private let apiKey: String

  init(with apiKey: String) {
    self.apiKey = apiKey
  }

  func createUVURL(lat: Double, lon: Double) -> URL {
    URL(string: K.Api.baseURL + String(format: K.Api.Endpoints.getUV, arguments: [lat, lon, self.apiKey]))!
  }

}
