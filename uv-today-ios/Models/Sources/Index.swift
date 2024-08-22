//
//  Index.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import UIKit

public typealias Index = Int

extension Index {
  
  public var associatedColor: UIColor {
    switch self {
    case 0: return UIColor.systemBlue
    case 1, 2: return UIColor.systemGreen
    case 3, 4, 5: return UIColor.systemYellow
    case 6, 7: return UIColor(red: 0.906, green: 0.373, blue: 0.184, alpha: 1)
    case 8, 9, 10: return UIColor.systemRed
    case 11, 12, 13, 14: return UIColor.systemPurple
    default : return UIColor.black
    }
  }
  
  public var associatedDescription: String {
    switch self {
    case 0, 1, 2:
      return "lowUV.desc".localized
    case 3, 4, 5:
      return "middleUV.desc".localized
    case 6, 7:
      return "highUV.desc".localized
    case 8, 9, 10:
      return "veryHighUV.desc".localized
    case 11, 12, 13, 14:
      return "extremeUV.desc".localized
    default:
      return "error.desc".localized
    }
  }
  
}
