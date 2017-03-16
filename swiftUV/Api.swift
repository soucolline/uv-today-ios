//
//  Api.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import CoreLocation

let API_CLIENT_ID = "sy9KaP1viQco8mDz94JSk"
let API_CLIENT_SECRET = "9RC0ImYhbS5Nu4Jgbma4AQt1iHHijxke2bin2mw5"

enum Api {
  case UVFromLocation(CLLocationDegrees, CLLocationDegrees)
  
  var url: String {
    switch(self) {
      case .UVFromLocation(let latitude, let longitude):
        return "http://api.aerisapi.com/forecasts/\(latitude),\(longitude)?client_id=\(API_CLIENT_ID)&client_secret=\(API_CLIENT_SECRET)"
    }
  }
}
