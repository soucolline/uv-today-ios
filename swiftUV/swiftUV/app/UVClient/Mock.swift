//
//  Mock.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Models

#if DEBUG
extension UVClient {
  static let mock = Self(
    fetchUVIndex: { _ in
      Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    },
    fetchCityName: { _ in
      "Gueugnon"
    }
  )
}

extension UVClient {
  static let unimplemented = Self(
    fetchUVIndex: XCTUnimplemented("\(Self.self).fetchUVIndex)"),
    fetchCityName: XCTUnimplemented("\(Self.self).fetchCityName")
  )
}
#endif
