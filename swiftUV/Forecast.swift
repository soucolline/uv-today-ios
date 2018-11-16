//
//  Forecast.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

struct Forecast: Codable {
  
  let currently: CurrentForecast
  
}

struct CurrentForecast: Codable {
  
  let uvIndex: Int
  
}
