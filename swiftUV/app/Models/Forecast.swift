//
//  Forecast.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

struct Forecast: Codable, TaskExecutable, Equatable {
  let lat: Double
  let lon: Double
  let dateIso: String
  let date: Int
  let value: Double

  enum CodingKeys: String, CodingKey {
    case lat
    case lon
    case dateIso = "date_iso"
    case date
    case value
  }
}
