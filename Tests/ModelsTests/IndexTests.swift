//
//  IndexTests.swift
//  swiftUVTests
//
//  Created by Zlatan on 18/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Models
import UIKit
import Testing

class IndexTests {
  
  @Test
  func getColorFromIndex() {
    for index in 0...15 {
      switch index {
      case 0: #expect(index.associatedColor == UIColor.systemBlue)
      case 1, 2: #expect(index.associatedColor == UIColor.systemGreen)
      case 3, 4, 5: #expect(index.associatedColor == UIColor.systemYellow)
      case 6, 7: #expect(index.associatedColor == UIColor(red: 0.906, green: 0.373, blue: 0.184, alpha: 1))
      case 8, 9, 10: #expect(index.associatedColor == UIColor.systemRed)
      case 11, 12, 13, 14: #expect(index.associatedColor == UIColor.systemPurple)
      default : #expect(index.associatedColor == UIColor.black)
      }
    }
  }
  
  @Test
  func getDescriptionFromIndex() {
    for index in 0...15 {
      switch index {
      case 0, 1, 2:
        #expect(index.associatedDescription == "lowUV.desc".localized)
      case 3, 4, 5:
        #expect(index.associatedDescription == "middleUV.desc".localized)
      case 6, 7:
        #expect(index.associatedDescription == "highUV.desc".localized)
      case 8, 9, 10:
        #expect(index.associatedDescription == "veryHighUV.desc".localized)
      case 11, 12, 13, 14:
        #expect(index.associatedDescription == "extremeUV.desc".localized)
      default:
        #expect(index.associatedDescription == "error.desc".localized)
      }
    }
  }
  
}
