//
//  String.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 17/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
  }
}
