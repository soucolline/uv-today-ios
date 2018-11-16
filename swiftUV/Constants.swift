//
//  Constants.swift
//  swiftUV
//
//  Created by Zlatan on 04/11/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation

struct K {
  
  struct Api {
    static let baseURL = "https://api.darksky.net/forecast/"
    
    struct Endpoints {
      static let getUV = "%@/%f,%f"
    }
    
  }
  
  struct i18n {
    static let lowUV = "lowUV.desc"
    static let middleUV = "middleUV.desc"
    static let highUV = "highUV.desc"
    static let veryHighUV = "veryHighUV.desc"
    static let extremeUV = "extremeUV.desc"
    static let error = "error.desc"
  }
  
}
