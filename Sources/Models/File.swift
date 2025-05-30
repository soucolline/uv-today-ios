//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 27/10/2022.
//

import Foundation

public struct AttributionResponse: Equatable, Sendable {
  public let logo: URL
  public let link: URL
  
  public init(logo: URL, link: URL) {
    self.logo = logo
    self.link = link
  }
}
