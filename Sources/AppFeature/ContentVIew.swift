//
//  ContentVIew.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import SwiftUI

public struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        Rectangle()
          .animation(.easeIn(duration: 0.5), value: viewStore.uvIndex.associatedColor)
          .foregroundColor(Color(viewStore.uvIndex.associatedColor))
          .edgesIgnoringSafeArea(.all)

        VStack {
          HStack {
            Spacer()
            
            Button {
              viewStore.send(.getUVRequest)
            } label: {
              Image(systemName: "arrow.clockwise")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .font(Font.title.weight(Font.Weight.thin))
                .foregroundColor(.white)
                .padding(.trailing, 20)
            }
            .disabled(viewStore.isLocationRefused)
          }

          HStack {
            Text(viewStore.cityName)
              .padding(.top, 33)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
              .redacted(reason: viewStore.getCityNameRequestInFlight ? .placeholder : [])
            Spacer()
          }

          Spacer()

          Text(String(viewStore.uvIndex))
            .foregroundColor(.white)
            .font(.system(size: 80, weight: .semibold, design: .rounded))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])

          Spacer()
          
          if viewStore.isLocationRefused {
            Button {
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
              Label("app.error.openSettings".localized, systemImage: "location")
            }
            .foregroundColor(.black)
            .padding(20)
            .background(Color.white)
            .cornerRadius(8)
          }
          
          Text(viewStore.uvIndex.associatedDescription)
            .padding(20)
            .foregroundColor(.white)
            .font(.system(size: 12))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])
        }
      }
      .alert(isPresented: viewStore.binding(\.$shouldShowErrorPopup)) {
        Alert(title: Text("app.label.error"), message: Text(viewStore.errorText))
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
        viewStore.send(.onAppear)
      }
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
        viewStore.send(.onDisappear)
      }
    }
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          uvIndex: 1,
          cityName: "Gueugnon",
          weatherRequestInFlight: false,
          getCityNameRequestInFlight: false
        ),
        reducer: appReducer,
        environment: AppEnvironment(
          uvClient: .mock,
          locationManager: .live
        )
      )
    )
  }
}
#endif
