//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 20/10/2022.
//

import Foundation

public enum UVError: Error, Equatable {
  
  case urlNotValid
  case noData(String)
  case couldNotDecodeJSON
  case noWeatherAvailable
  case noAttributionAvailable
  case customError(String)
  
  public var localizedDescription: String {
    switch self {
    case .urlNotValid:
      return "Url is invalid"
    case .noData(let message):
      return message
    case .couldNotDecodeJSON:
      return "Could not parse JSON"
    case .noWeatherAvailable:
      return "No weather data available"
    case .noAttributionAvailable:
      return "No attribution available for WeatherKit"
    case .customError(let message):
      return message
    }
  }
  
}
