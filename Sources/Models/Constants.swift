//
//  Constants.swift
//  swiftUV
//
//  Created by Zlatan on 04/11/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

public struct K {
  public struct Api {
    public static let baseURL = "https://api.openweathermap.org/data/2.5/"
    
    public struct Endpoints {
      public static let getUV = "uvi?lat=%.4f&lon=%.4f&appid=%@"
    }
  }
}
