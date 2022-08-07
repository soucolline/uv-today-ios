//
//  Mock.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import Foundation
import ComposableArchitecture

#if DEBUG
extension UVClient {
  static let mock = Self(
    fetchUVIndex: { _ in
      Effect(value: Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5))
    },
    fetchCityName: { _ in
      Effect(value: "Gueugnon")
    }
  )
}
#endif
