//
//  ContentVIew.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var uvIndex: Index = 0
  var cityName = ""
  var weatherRequestInFlight = false
}

enum AppAction: Equatable {
  
}

struct AppEnvironment {
  
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  
  }
}

struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        Rectangle()
          .animation(Animation.easeIn(duration: 1.0))
          .foregroundColor(Color(viewStore.uvIndex.associatedColor))
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
                //self.viewModel.searchLocation()
              }
          }

          HStack {
            Text(viewStore.cityName)
              .padding(.top, 33)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
              .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])
            Spacer()
          }

          Spacer()

          Text(String(viewStore.uvIndex))
            .foregroundColor(.white)
            .font(.custom("OpenSans-Semibold", size: 80))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])

          Spacer()

          Text(viewStore.uvIndex.associatedDescription)
            .padding(20)
            .foregroundColor(.white)
            .font(.custom("OpenSans", size: 12))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])
        }
      }
    }
    //.blur(radius: self.viewModel.showErrorPopup ? 3 : 0)
//    .popup(isPresented: self.$viewModel.showErrorPopup) {
//      VStack {
//        Text(self.viewModel.errorText)
//          .foregroundColor(.gray)
//          .padding(.bottom, 20)
//        Button("Retry") {
//          self.viewModel.getUVIndex()
//        }
//      }
//      .padding(20)
//      .background(Color.white)
//      .cornerRadius(20)
//    }
//    .onAppear {
//      self.viewModel.getUVIndex()
//    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          uvIndex: 1,
          cityName: "Gueugnon",
          weatherRequestInFlight: false
        ),
        reducer: appReducer,
        environment: AppEnvironment()
      )
    )
  }
}
