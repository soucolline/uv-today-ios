//
//  UVClientRequest.swift
//  uv-today-ios
//
//  Created by Thomas Guilleminot on 29/05/2025.
//


public struct UVClientRequest {
  public let lat: Double
  public let long: Double
  
  public init(lat: Double, long: Double) {
    self.lat = lat
    self.long = long
  }
}
