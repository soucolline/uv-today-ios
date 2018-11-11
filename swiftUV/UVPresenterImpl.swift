//
//  UVPresenterImpl.swift
//  swiftUV
//
//  Created by Zlatan on 11/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Foundation

protocol UVViewDelegate: class {
  func onShowLoader()
  func onDismissLoader()
  
  func onShowLoaderForLocationSearch()
  
  func onUpdateLocationWithSuccess()
  func onUpdateLocationWithError()
  
  func onAcceptLocation()
  func onShowRefusedLocation()
}

protocol UVPresenter {
  func searchLocation()
}

class UVPresenterImpl: UVPresenter {
  
  weak var delegate: UVViewDelegate?
  
  let locationService: LocationService
  
  init(with delegate: UVViewDelegate, locationService: LocationService) {
    self.delegate = delegate
    self.locationService = locationService
    self.locationService.delegate = self
  }
  
  func searchLocation() {
    self.delegate?.onShowLoaderForLocationSearch()
    self.locationService.searchLocation()
  }
  
}

extension UVPresenterImpl: LocationServiceDelegate {
  
  func didUpdateLocation() {
    self.delegate?.onDismissLoader()
    self.delegate?.onUpdateLocationWithSuccess()
  }
  
  func didFailUpdateLocation() {
    self.delegate?.onDismissLoader()
    self.delegate?.onUpdateLocationWithError()
  }
  
  func didAcceptLocationService() {
    self.delegate?.onDismissLoader()
    self.delegate?.onAcceptLocation()
  }
  
  func didRefuseLocationService() {
    self.delegate?.onDismissLoader()
    self.delegate?.onShowRefusedLocation()
  }
  
}
