//
//  UVPresenterImpl.swift
//  swiftUV
//
//  Created by Zlatan on 11/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

protocol UVViewDelegate: class {
  func onShowLoader()
  func onDismissLoader()
  
  func onUpdateLocationWithSuccess(with cityName: String)
  func onUpdateLocationWithError()
  
  func onReceiveSuccess(index: Int)
  func onShowError(message: String)
  
  func onAcceptLocation()
  func onShowRefusedLocation()
}

protocol UVPresenter {
  func searchLocation()
  func getUVIndex()
}

class UVPresenterImpl: UVPresenter {
  
  weak var delegate: UVViewDelegate?
  private var location: Location?
  
  private let locationService: LocationService
  private let uvService: UVService
  
  init(with delegate: UVViewDelegate, locationService: LocationService, uvService: UVService) {
    self.delegate = delegate
    self.locationService = locationService
    self.uvService = uvService
    self.locationService.delegate = self
  }
  
  func searchLocation() {
    self.delegate?.onShowLoader()
    self.locationService.searchLocation()
  }
  
  func getUVIndex() {
    guard let location = self.location else { return }
    
    self.uvService.getUVIndex(from: location, success: { forecast in
      self.delegate?.onDismissLoader()
      self.delegate?.onReceiveSuccess(index: forecast.currently.uvIndex)
    }, failure: { error in
      self.delegate?.onDismissLoader()
      self.delegate?.onShowError(message: error.localizedDescription)
    })
  }
  
}

extension UVPresenterImpl: LocationServiceDelegate {
  
  func didUpdateLocation(_ location: Location) {
    self.location = location
    self.delegate?.onUpdateLocationWithSuccess(with: location.city)
    self.getUVIndex()
  }
  
  func didFailUpdateLocation() {
    self.delegate?.onDismissLoader()
    self.delegate?.onUpdateLocationWithError()
  }
  
  func didAcceptLocationService() {
    self.delegate?.onAcceptLocation()
  }
  
  func didRefuseLocationService() {
    self.delegate?.onDismissLoader()
    self.delegate?.onShowRefusedLocation()
  }
  
}
