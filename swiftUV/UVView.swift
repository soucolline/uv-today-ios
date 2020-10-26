//
//  UVView.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 26/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import SwiftUI

struct UVView: View {
    var body: some View {
      ZStack {
        Rectangle()
          .foregroundColor(.green)
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
            Text("Gueugnon")
              .padding(.top, 33)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.leading, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
            Spacer()
          }

          Spacer()

          Text("8")
            .foregroundColor(.white)
            .font(.custom("OpenSans-Semibold", size: 80))

          Spacer()

          Text("Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
            .padding(20)
            .foregroundColor(.white)
            .font(.custom("OpenSans", size: 12))
        }
      }
    }
}

struct UVView_Previews: PreviewProvider {
    static var previews: some View {
      UVView()
    }
}
