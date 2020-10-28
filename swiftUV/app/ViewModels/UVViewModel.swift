//
//  UVViewModel.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 26/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Combine
import ZLogger

class UVViewModel: ObservableObject {

  @Published var cityLabel = "Loading"
  @Published var index: Index = 0
  @Published var showLoading = false
  @Published var showErrorPopup = false
  @Published var errorText = ""

  private let locationService: LocationService
  private let uvService: UVService

  private var location: Location?
  private var cancelable: AnyCancellable?

  init(locationService: LocationService, uvService: UVService) {
    self.locationService = locationService
    self.uvService = uvService

    self.locationService.delegate = self
  }

  func searchLocation() {
    self.showLoading = true
    self.locationService.searchLocation()
  }

  func getUVIndex() {
    guard let location = self.location else {
      self.searchLocation()
      return
    }

    self.cancelable = self.uvService.getUVIndex(from: location)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
          case .finished: break
          case .failure(let error):
            self.showLoading = false
            self.showErrorPopup = true
            self.errorText = error.localizedDescription
        }
      } receiveValue: { value in
        ZLogger.info(message: "Did receive index with value : \(value)")
        self.index = value
        self.showLoading = false
      }
  }

  private func showError(message: String) {
    self.showLoading = false
    self.showErrorPopup = true
    self.errorText = message
    self.index = Index(-1)
  }

}

extension UVViewModel: LocationServiceDelegate {

  func didUpdateLocation(_ location: Location) {
    self.location = location
    self.cityLabel = location.city

    self.getUVIndex()
  }

  func didFailUpdateLocation() {
    self.showError(message: "app.error.couldNotLocalise".localized)
  }

  func didAcceptLocationService() {
    self.searchLocation()
  }

  func didRefuseLocationService() {
    self.showError(message: "app.error.localisationDisabled".localized)
  }
  
}
