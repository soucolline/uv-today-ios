//
//  Index.swift
//  swiftUV
//
//  Created by Zlatan on 16/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import UIKit

typealias Index = Int

extension Index {
  
  var associatedColor: UIColor {
    switch self {
    case 0: return #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
    case 1, 2: return #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1)
    case 3, 4, 5: return #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1)
    case 6, 7: return #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
    case 8, 9, 10: return #colorLiteral(red: 0.7529411765, green: 0.2235294118, blue: 0.168627451, alpha: 1)
    case 11, 12, 13, 14: return #colorLiteral(red: 0.6078431373, green: 0.3490196078, blue: 0.7137254902, alpha: 1)
    default : return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
  }
  
  var associatedDescription: String {
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
