//
//  IndexTests.swift
//  swiftUVTests
//
//  Created by Zlatan on 18/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import XCTest
import Nimble

@testable import swiftUV

class IndexTests: XCTestCase {
  
  func testGetColorFromIndex() {
    for index in 0...15 {
      switch index {
      case 0: expect(index.associatedColor) == #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
      case 1, 2: expect(index.associatedColor) == #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1)
      case 3, 4, 5: expect(index.associatedColor) == #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1)
      case 6, 7: expect(index.associatedColor) == #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
      case 8, 9, 10: expect(index.associatedColor) == #colorLiteral(red: 0.7529411765, green: 0.2235294118, blue: 0.168627451, alpha: 1)
      case 11, 12, 13, 14: expect(index.associatedColor) == #colorLiteral(red: 0.6078431373, green: 0.3490196078, blue: 0.7137254902, alpha: 1)
      default : expect(index.associatedColor) == #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
      }
    }
  }
  
  func testGetDescriptionFromIndex() {
    for index in 0...15 {
      switch index {
      case 0, 1, 2:
        expect(index.associatedDescription) == "lowUV.desc".localized
      case 3, 4, 5:
        expect(index.associatedDescription) == "middleUV.desc".localized
      case 6, 7:
        expect(index.associatedDescription) == "highUV.desc".localized
      case 8, 9, 10:
        expect(index.associatedDescription) == "veryHighUV.desc".localized
      case 11, 12, 13, 14:
        expect(index.associatedDescription) == "extremeUV.desc".localized
      default:
        expect(index.associatedDescription) == "error.desc".localized
      }
    }
  }
  
}
