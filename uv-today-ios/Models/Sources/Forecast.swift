//
//  Forecast.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

public struct Forecast: Codable, Equatable {
  public let lat: Double
  public let lon: Double
  public let dateIso: String
  public let date: Int
  public let value: Double
  
  public init(lat: Double, lon: Double, dateIso: String, date: Int, value: Double) {
    self.lat = lat
    self.lon = lon
    self.dateIso = dateIso
    self.date = date
    self.value = value
  }

  enum CodingKeys: String, CodingKey {
    case lat
    case lon
    case dateIso = "date_iso"
    case date
    case value
  }
}
