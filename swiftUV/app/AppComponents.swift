//
//  AppComponents.swift
//  swiftUV
//
//  Created by Zlatan on 18/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Swinject
import CoreLocation

class AppComponent {
  
  func getContainer() -> Container {
    let container = Container()
    
    container.register(CLLocationManager.self) { _ in
      return CLLocationManager()
    }
    
    container.register(LocationService.self) { resolver in
      return LocationService(
        with: resolver.resolve(CLLocationManager.self)!
      )
    }
    
    container.register(NetworkSession.self) { _ in
      let session = URLSessionConfiguration.default
      session.timeoutIntervalForRequest = 10.0
      return URLSession(configuration: session)
    }
    
    container.register(APIWorker.self) { resolver in
        APIWorkerImpl(
          with: resolver.resolve(NetworkSession.self)!
      )
    }
    
    container.register(UVService.self) { resolver in
      return UVServiceImpl(
        with: resolver.resolve(APIWorker.self)!
      )
    }
    
    container.register(UVPresenter.self) { resolver in
      return UVPresenterImpl(
        with: resolver.resolve(LocationService.self)!,
        uvService: resolver.resolve(UVService.self)!
      )
    }
    
    return container
  }
  
}
