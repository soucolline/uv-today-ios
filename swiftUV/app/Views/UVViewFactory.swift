//
//  UVViewFactory.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 26/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import SwiftUI

struct UVViewFactory: ViewFactory {

  private let viewModel: UVViewModel

  init(with viewModel: UVViewModel) {
    self.viewModel = viewModel
  }

  func make() -> AnyView {
    AnyView(UVView(viewModel: self.viewModel))
  }

}
