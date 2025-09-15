//
//  ContentVIew.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import SwiftUI

public struct UVScreen: View {
  @Environment(\.scenePhase) var scenePhase
  
  @Bindable private var viewModel: UVScreenViewModel
  
  public init(viewModel: UVScreenViewModel) {
    self.viewModel = viewModel
  }
  
  public var body: some View {
    NavigationStack {
      ZStack {
        Rectangle()
          .animation(.easeIn(duration: 0.5), value: viewModel.uvIndex.associatedColor)
          .foregroundColor(Color(viewModel.uvIndex.associatedColor))
          .edgesIgnoringSafeArea(.all)
        
        VStack {
          HStack {
            Spacer()
          }
          
          HStack {
            Text(viewModel.cityName)
              .padding(.top, 12)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
              .redacted(reason: viewModel.getCityNameRequestInFlight ? .placeholder : [])
            Spacer()
          }
          
          Spacer()
          
          Text(String(viewModel.uvIndex))
            .foregroundColor(.white)
            .font(.system(size: 80, weight: .semibold, design: .rounded))
            .redacted(reason: viewModel.weatherRequestInFlight ? .placeholder : [])
          
          Spacer()
          
          if viewModel.isLocationRefused {
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
          
          Text(viewModel.uvIndex.associatedDescription)
            .padding(20)
            .foregroundColor(.white)
            .font(.system(size: 12))
            .redacted(reason: viewModel.weatherRequestInFlight ? .placeholder : [])
          
          if let attributionLogo = viewModel.attributionLogo {
            AsyncImage(url: attributionLogo, content: { image in
              image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
            }, placeholder: {
              
            })
          }
          
          if let attributionLink = viewModel.attributionLink {
            Link(destination: attributionLink, label: { Text("Other data sources")})
              .foregroundColor(.white)
          }
        }
      }
      .alert(isPresented: $viewModel.shouldShowErrorPopup) {
        Alert(title: Text("app.label.error"), message: Text(viewModel.errorText))
      }
      .onChange(of: scenePhase) { _, newValue in
        switch newValue {
        case .active: viewModel.onAppear()
        case .inactive, .background: viewModel.onDisappear()
        @unknown default: break
        }
      }
      .task {
        if #available(iOS 16.0, *) {
          await viewModel.getAtribution()
        }
      }
      .toolbar {
        ToolbarItem {
          Button {
            Task {
              await viewModel.getUVRequest()
            }
          } label: {
            Image(systemName: "arrow.clockwise")
              .resizable()
              .frame(width: 20, height: 20, alignment: .center)
              .font(Font.title.weight(Font.Weight.bold))
              .toolbarColor()
              .padding()
          }
          .disabled(viewModel.isLocationRefused)
        }
      }
    }
  }
}

#Preview {
  UVScreen(viewModel: UVScreenViewModel())
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
