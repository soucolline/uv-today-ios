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

  private let locationService: LocationService
  private let uvService: UVService

  private var location: Location?
  weak var delegate: UVViewDelegate?
  private var cancelable: AnyCancellable?

  init(locationService: LocationService, uvService: UVService) {
    self.locationService = locationService
    self.uvService = uvService

    self.locationService.delegate = self
    self.locationService.searchLocation()
  }

  func getUVIndex() {
    guard let location = self.location else { return }

    self.cancelable = self.uvService.getUVIndex(from: location)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
          case .finished: break
          case .failure(let error):
            self.delegate?.onDismissLoader()
            self.delegate?.onShowError(message: error.localizedDescription)
        }
      } receiveValue: { value in
        ZLogger.info(message: "Did receive index with value : \(value)")
        self.index = value

        self.delegate?.onDismissLoader()
        self.delegate?.onReceiveSuccess(index: value)
      }
  }

}

extension UVViewModel: LocationServiceDelegate {

  func didUpdateLocation(_ location: Location) {
    self.location = location
    self.cityLabel = location.city

    self.getUVIndex()
  }

  func didFailUpdateLocation() {
//    self.delegate?.onDismissLoader()
//    self.delegate?.onUpdateLocationWithError()
  }

  func didAcceptLocationService() {
//    self.delegate?.onAcceptLocation()
  }

  func didRefuseLocationService() {
//    self.delegate?.onDismissLoader()
//    self.delegate?.onShowRefusedLocation()
  }
  
}
