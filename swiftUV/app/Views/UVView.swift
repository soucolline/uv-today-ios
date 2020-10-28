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
import ExytePopupView

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
            .onTapGesture {
              self.viewModel.searchLocation()
            }
        }

        HStack {
          Text(self.viewModel.cityLabel)
            .padding(.top, 33)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.leading, 20)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .redacted(reason: self.viewModel.showLoading ? .placeholder : [])
          Spacer()
        }

        Spacer()

        Text(String(self.viewModel.index))
          .foregroundColor(.white)
          .font(.custom("OpenSans-Semibold", size: 80))
          .redacted(reason: self.viewModel.showLoading ? .placeholder : [])

        Spacer()

        Text(self.viewModel.index.associatedDescription)
          .padding(20)
          .foregroundColor(.white)
          .font(.custom("OpenSans", size: 12))
          .redacted(reason: self.viewModel.showLoading ? .placeholder : [])
      }
    }
    .blur(radius: self.viewModel.showErrorPopup ? 3 : 0)
    .popup(isPresented: self.$viewModel.showErrorPopup) {
      VStack {
        Text(self.viewModel.errorText)
          .foregroundColor(.gray)
          .padding(.bottom, 20)
        Button("Retry") {
          self.viewModel.getUVIndex()
        }
      }
      .padding(20)
      .background(Color.white)
      .cornerRadius(20)
    }
    .onAppear {
      self.viewModel.getUVIndex()
    }
  }
}

struct UVView_Previews: PreviewProvider {
  static var previews: some View {
    UVView(viewModel: Resolver.resolve(UVViewModel.self))
  }
}
