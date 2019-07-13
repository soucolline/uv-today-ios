//
//  UVError.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

enum UVError: Error, Equatable {
  
  case urlNotValid
  case noData
  case couldNotDecodeJSON
  case customError(String)
  
  var localizedDescription: String {
    switch self {
    case .urlNotValid:
      return "Url is invalid"
    case .noData:
      return "app.error.noData".localized
    case .couldNotDecodeJSON:
      return "Could not parse JSON"
    case .customError(let message):
      return message
    }
  }
  
}
