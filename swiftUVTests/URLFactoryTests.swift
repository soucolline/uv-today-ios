//
//  URLFactoryTests.swift
//  swiftUVTests
//
//  Created by Thomas Guilleminot on 18/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import XCTest

@testable import swiftUV

class URLFactoryTests: XCTestCase {

  func testCreateURL() {
    let expectedURL = "https://api.openweathermap.org/data/2.5/uvi?lat=48.8534&lon=2.3488&appid=123456"
    let expectedLat = 48.8534
    let expectedLon = 2.3488
    let expectedAppId = "123456"

    let factory = URLFactory(with: expectedAppId)

    XCTAssertEqual(factory.createUVURL(lat: expectedLat, lon: expectedLon), URL(string: expectedURL)!)
  }

}
