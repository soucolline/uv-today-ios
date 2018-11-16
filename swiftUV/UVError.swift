//
//  UVError.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

enum UVError: Error {
  
  case noData
  
  var localizedDescription: String {
    switch self {
    case .noData:
      return "No data available"
    }
  }
  
}
