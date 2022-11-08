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
  public static let mock = Self(
    fetchUVIndex: { _ in
      5
    },
    fetchCityName: { _ in
      "Gueugnon"
    },
    fetchWeatherKitAttribution: {
      AttributionResponse(
        logo: URL(string:"https://www.logo.com")!,
        link: URL(string: "https://www.link.com")!
      )
    }
  )
}

extension UVClientKey {
  static let testValue = UVClient.unimplemented
  static let previewValue = UVClient.mock
}

extension UVClient {
  public static let unimplemented = Self(
    fetchUVIndex: XCTUnimplemented("\(Self.self).fetchUVIndex)"),
    fetchCityName: XCTUnimplemented("\(Self.self).fetchCityName"),
    fetchWeatherKitAttribution: XCTUnimplemented("\(Self.self).fetchWeatherKitAttribution")
  )
}
#endif
