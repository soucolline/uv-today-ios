//
//  AppComponent+Injection.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 23/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Resolver
import Keys
import CoreLocation

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    registerViewModule()
    registerViewModelModule()
    registerNetworkModule()
    registerServiceModule()
    registerPresenterModule()
    registerAppModule()
    registerLocationModule()
  }
}

extension Resolver {
  public static func registerViewModule() {
    register(UVViewFactory.self) {
      UVViewFactory(with: resolve(UVViewModel.self))
    }
  }
}

extension Resolver {
  public static func registerViewModelModule() {
    register(UVViewModel.self) {
      UVViewModel(
        locationService: resolve(LocationService.self),
        uvService: resolve(UVService.self)
      )
    }
  }
}

extension Resolver {
  public static func registerNetworkModule() {
    register(NetworkSession.self) {
      let session = URLSessionConfiguration.default
      session.timeoutIntervalForRequest = 10.0
      return URLSession(configuration: session)
    }

    register(APIWorker.self) { APIWorkerImpl(with: resolve(NetworkSession.self)) }
  }
}

extension Resolver {
  public static func registerServiceModule() {
    register(UVService.self) {
      UVServiceImpl(apiExecutor: resolve(APIWorker.self), urlFactory: resolve(URLFactory.self))
    }
  }
}

extension Resolver {
  public static func registerPresenterModule() {
    register(UVPresenter.self) {
      UVPresenterImpl(locationService: resolve(LocationService.self), uvService: resolve(UVService.self))
    }
  }
}

extension Resolver {
  public static func registerLocationModule() {
    register(CLLocationManager.self) { CLLocationManager() }
    register(LocationService.self) {
      LocationService(locationManager: resolve(CLLocationManager.self))
    }
  }
}

extension Resolver {
  public static func registerAppModule() {
    register(URLFactory.self) { URLFactory(with: SwiftUVKeys().openWeatherMapApiKey) }
  }
}
