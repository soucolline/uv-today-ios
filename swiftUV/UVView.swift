//
//  UVView.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 26/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import SwiftUI
import CoreLocation
import Resolver

struct UVView: View {

  @ObservedObject var viewModel: UVViewModel

  var body: some View {
    ZStack {
      Rectangle()
        .animation(Animation.easeIn(duration: 1.0))
        .foregroundColor(Color(self.viewModel.index.associatedColor))
        .edgesIgnoringSafeArea(.all)

      VStack {
        HStack {
          Spacer()
          Image(systemName: "arrow.clockwise")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .font(Font.title.weight(Font.Weight.thin))
            .foregroundColor(.white)
            .padding(.trailing, 20)
        }

        HStack {
          Text(self.viewModel.cityLabel)
            .padding(.top, 33)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.leading, 20)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
          Spacer()
        }

        Spacer()

        Text(String(self.viewModel.index))
          .foregroundColor(.white)
          .font(.custom("OpenSans-Semibold", size: 80))

        Spacer()

        Text(self.viewModel.index.associatedDescription)
          .padding(20)
          .foregroundColor(.white)
          .font(.custom("OpenSans", size: 12))
      }
    }
  }
}

struct UVView_Previews: PreviewProvider {
  static var previews: some View {
    UVView(viewModel: Resolver.resolve(UVViewModel.self))
  }
}
