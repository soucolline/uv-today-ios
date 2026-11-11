//
//  ContentVIew.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import Models
import SwiftUI

public struct UVScreen: View {
  @Environment(\.scenePhase) var scenePhase
  
  private let store: StoreOf<UVFeature>
  
  public init(store: StoreOf<UVFeature>) {
    self.store = store
  }
  
  public var body: some View {
    if #available(iOS 27.1, *) {
      navigation
        .toolbarVerticalBehavior(.disabled)
    } else {
      navigation
    }
  }

  private var navigation: some View {
    NavigationStack {
      ZStack {
        Rectangle()
          .animation(.easeIn(duration: 0.5), value: store.uvIndex.associatedColor)
          .foregroundColor(Color(store.uvIndex.associatedColor))
          .edgesIgnoringSafeArea(.all)
        
        VStack {
          HStack {
            Spacer()
          }
          
          HStack {
            Text(store.cityName)
              .padding(.top, 12)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
              .redacted(reason: store.loading != nil ? .placeholder : [])
            Spacer()
          }
          
          Spacer()
          
          Text(String(store.uvIndex))
            .foregroundColor(.white)
            .font(.system(size: 80, weight: .semibold, design: .rounded))
            .redacted(reason: store.loading != nil ? .placeholder : [])
          
          Spacer()
          
          if store.isLocationRefused {
            Button {
              store.send(.openSettingsButtonTapped)
            } label: {
              Label("app.error.openSettings".localized, systemImage: "location")
            }
            .foregroundColor(.black)
            .padding(20)
            .background(Color.white)
            .cornerRadius(8)
          }
          
          Text(store.uvIndex.associatedDescription)
            .multilineTextAlignment(.center)
            .padding(20)
            .foregroundColor(.white)
            .font(.system(size: 12))
            .redacted(reason: store.loading != nil ? .placeholder : [])
          
          if let attributionLogo = store.attribution?.logo {
            AsyncImage(url: attributionLogo, content: { image in
              image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
            }, placeholder: {
              
            })
          }
          
          if let attributionLink = store.attribution?.link {
            Link(destination: attributionLink, label: { Text("Other data sources")})
              .foregroundColor(.white)
          }
        }
      }
      .alert(
        "app.label.error",
        isPresented: Binding(
          get: { store.errorText != nil },
          set: { if !$0 { store.send(.errorDismissed) } }
        )
      ) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(store.errorText ?? "")
      }
      .onChange(of: scenePhase, initial: true) { _, phase in
        switch phase {
        case .active: store.send(.sceneBecameActive)
        case .background: store.send(.sceneEnteredBackground)
        case .inactive: break
        @unknown default: break
        }
      }
      .onDisappear { store.send(.screenDisappeared) }
      .task { await store.send(.screenTask).finish() }
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.refreshButtonTapped)
          } label: {
            Image(systemName: "arrow.clockwise")
              .resizable()
              .frame(width: 20, height: 20, alignment: .center)
              .font(Font.title.weight(Font.Weight.bold))
              .toolbarColor()
              .padding()
          }
          .disabled(store.isLocationRefused || store.loading != nil)
        }
      }
    }
  }
}

#Preview {
  UVScreen(
    store: Store(initialState: UVFeature.State()) {
      Reduce<UVFeature.State, UVFeature.Action> { _, _ in .none }
    }
  )
}

extension View {
  @ViewBuilder
  func toolbarColor() -> some View {
    if #unavailable(iOS 26) {
      foregroundColor(.white)
    } else {
      self
    }
  }
}
