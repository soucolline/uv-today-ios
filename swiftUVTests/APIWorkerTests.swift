//
//  APIWorkerTests.swift
//  swiftUVTests
//
//  Created by Thomas Guilleminot on 28/06/2019.
//  Copyright © 2019 Thomas Guilleminot. All rights reserved.
//

import XCTest
import Cuckoo

@testable import swiftUV

class APIWorkerTests: XCTestCase {
  
  var sessionMock: MockNetworkSession!
  var apiWorker: APIWorker!
  
  override func setUp() {
    sessionMock = MockNetworkSession()
    apiWorker = APIWorkerImpl(with: sessionMock)
  }
  
  func testLoadDataSuccess() {
    let expectedURL = URL(string: "https://www.fake-url.com")!
    let forecast = Forecast(currently: CurrentForecast(uvIndex: 1))
    let forecastData = try! JSONEncoder().encode(forecast)
    
    stub(sessionMock) { stub in
      when(stub).loadData(from: any(), completionHandler: any()).then({ url, completionHandler in
        completionHandler(forecastData, nil)
      })
    }
    
    apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:], completion: { result in
      verify(self.sessionMock).loadData(from: ParameterMatcher(matchesFunction: { url in
        url == expectedURL
      }), completionHandler: any())
      
      XCTAssertEqual(try! result.get().currently.uvIndex, 1)
    })
    
    verifyNoMoreInteractions(sessionMock)
  }

  
  func testLoadDataFailedCustomError() {
    let expectedURL = URL(string: "https://www.fake-url.com")!
    
    stub(sessionMock) { stub in
      when(stub).loadData(from: any(), completionHandler: any()).then({ url, completionHandler in
        completionHandler(nil, UVError.couldNotDecodeJSON)
      })
    }
    
    apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:], completion: { result in
      verify(self.sessionMock).loadData(from: ParameterMatcher(matchesFunction: { url in
        url == expectedURL
      }), completionHandler: any())
      
      _ = result.mapError { error -> UVError in
        XCTAssertEqual(error, UVError.customError(error.localizedDescription))
        
        return error
      }
    })
    
    verifyNoMoreInteractions(sessionMock)
  }
  
  func testLoadDataFailedNoData() {
    let expectedURL = URL(string: "https://www.fake-url.com")!
    
    stub(sessionMock) { stub in
      when(stub).loadData(from: any(), completionHandler: any()).then({ url, completionHandler in
        completionHandler(nil, nil)
      })
    }
    
    apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:], completion: { result in
      verify(self.sessionMock).loadData(from: ParameterMatcher(matchesFunction: { url in
        url == expectedURL
      }), completionHandler: any())
      
      _ = result.mapError { error -> UVError in
        XCTAssertEqual(error, UVError.noData)
        
        return error
      }
    })
    
    verifyNoMoreInteractions(sessionMock)
  }
  
  func testLoadDataFailedCouldNotDecodeJSON() {
    let expectedURL = URL(string: "https://www.fake-url.com")!
    let dataToFail = "///".data(using: .utf8)
    
    stub(sessionMock) { stub in
      when(stub).loadData(from: any(), completionHandler: any()).then({ url, completionHandler in
        completionHandler(dataToFail, nil)
      })
    }
    
    apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:], completion: { result in
      verify(self.sessionMock).loadData(from: ParameterMatcher(matchesFunction: { url in
        url == expectedURL
      }), completionHandler: any())
      
      _ = result.mapError { error -> UVError in
        XCTAssertEqual(error, UVError.couldNotDecodeJSON)
        
        return error
      }
    })
    
    verifyNoMoreInteractions(sessionMock)
  }

  
}

