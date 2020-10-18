//
//  Constants.swift
//  swiftUV
//
//  Created by Zlatan on 04/11/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

struct K {
  
  struct Api {
    static let baseURL = "https://api.openweathermap.org/data/2.5/"
    
    struct Endpoints {
      static let getUV = "uvi?lat=%f&lon=%f&appid=%@"
    }
    
  }
  
}
