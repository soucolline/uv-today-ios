//
//  IndexTests.swift
//  swiftUVTests
//
//  Created by Zlatan on 18/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import XCTest

@testable import swiftUV

class IndexTests: XCTestCase {
  
  func testGetColorFromIndex() {
    for index in 0...15 {
      switch index {
      case 0: XCTAssertEqual(index.associatedColor, UIColor.systemBlue)
      case 1, 2: XCTAssertEqual(index.associatedColor, UIColor.systemGreen)
      case 3, 4, 5: XCTAssertEqual(index.associatedColor, UIColor.systemYellow)
      case 6, 7: XCTAssertEqual(index.associatedColor, UIColor(named: "LightRed")!)
      case 8, 9, 10: XCTAssertEqual(index.associatedColor, UIColor.systemRed)
      case 11, 12, 13, 14: XCTAssertEqual(index.associatedColor, UIColor.systemPurple)
      default : XCTAssertEqual(index.associatedColor, UIColor.black)
      }
    }
  }
  
  func testGetDescriptionFromIndex() {
    for index in 0...15 {
      switch index {
      case 0, 1, 2:
        XCTAssertEqual(index.associatedDescription, "lowUV.desc".localized)
      case 3, 4, 5:
        XCTAssertEqual(index.associatedDescription, "middleUV.desc".localized)
      case 6, 7:
        XCTAssertEqual(index.associatedDescription, "highUV.desc".localized)
      case 8, 9, 10:
        XCTAssertEqual(index.associatedDescription, "veryHighUV.desc".localized)
      case 11, 12, 13, 14:
        XCTAssertEqual(index.associatedDescription, "extremeUV.desc".localized)
      default:
        XCTAssertEqual(index.associatedDescription, "error.desc".localized)
      }
    }
  }
  
}
