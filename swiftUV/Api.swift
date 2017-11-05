//
//  Api.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import CoreLocation

let API_CLIENT_SECRET = "cc3256542b7071cba719d7ccd2b03c39"

enum Api {
  case UVFromLocation(CLLocationDegrees, CLLocationDegrees)
  
  var url: String {
    switch self {
      case .UVFromLocation(let latitude, let longitude):
        return "https://api.darksky.net/forecast/\(API_CLIENT_SECRET)/\(latitude),\(longitude)"
    }
  }
}
