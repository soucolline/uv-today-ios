//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 08/11/2022.
//

import Foundation
import Dependencies

enum UVClientKey: DependencyKey {
  static let liveValue: any UVClient = UVClientImpl()
}

public extension DependencyValues {
  var uvClient: UVClient {
    get { self[UVClientKey.self] }
    set { self[UVClientKey.self] = newValue }
  }
}
