//
//  APIWorkerTests.swift
//  swiftUVTests
//
//  Created by Thomas Guilleminot on 28/06/2019.
//  Copyright © 2019 Thomas Guilleminot. All rights reserved.
//

import XCTest
import Cuckoo
import Combine

@testable import swiftUV

class APIWorkerTests: XCTestCase {
  
  var sessionMock: MockNetworkSession!
  var apiWorker: APIWorker!

  private let expectedURL = URL(string: "https://www.fake-url.com")!
  private let expectedForecast = Forecast(lat: 10.212, lon: 43.232, dateIso: "12154215", date: 1234566, value: 1)

  private var cancelable: AnyCancellable?
  
  override func setUp() {
    sessionMock = MockNetworkSession()
    apiWorker = APIWorkerImpl(with: sessionMock)
  }
  
  func testLoadDataSuccess() {
    let forecastData = try! JSONEncoder().encode(expectedForecast)
    let expectedURLResponse = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let expectedPublisher = Just((data: forecastData, response: expectedURLResponse as URLResponse)).setFailureType(to: URLError.self).eraseToAnyPublisher()

    stub(sessionMock) { stub in
      when(stub).loadData(from: any()).thenReturn(expectedPublisher)
    }

    cancelable = apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:]).sink { completion in
      switch completion {
        case .finished: break
        case .failure: XCTFail("Should not trigger failure")
      }
    } receiveValue: { forecast in
      XCTAssertEqual(forecast, self.expectedForecast)
    }

    verify(sessionMock).loadData(from: any())
    verifyNoMoreInteractions(sessionMock)
  }

  func testLoadDataFailureNoResponse() {
    let forecastData = try! JSONEncoder().encode(expectedForecast)
    let expectedURLResponse = URLResponse()
    let expectedPublisher = Just((data: forecastData, response: expectedURLResponse)).setFailureType(to: URLError.self).eraseToAnyPublisher()

    stub(sessionMock) { stub in
      when(stub).loadData(from: any()).thenReturn(expectedPublisher)
    }

    cancelable = apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:]).sink { completion in
      switch completion {
        case .finished: break
        case .failure(let error): XCTAssertEqual(error, UVError.urlNotValid)
      }
    } receiveValue: { forecast in
      XCTFail("Should not trigger success")
    }

    verify(sessionMock).loadData(from: any())
    verifyNoMoreInteractions(sessionMock)
  }

  func testLoadDataFailure404() {
    let forecastData = try! JSONEncoder().encode(expectedForecast)
    let expectedURLResponse = HTTPURLResponse(url: expectedURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
    let expectedPublisher = Just((data: forecastData, response: expectedURLResponse as URLResponse)).setFailureType(to: URLError.self).eraseToAnyPublisher()

    stub(sessionMock) { stub in
      when(stub).loadData(from: any()).thenReturn(expectedPublisher)
    }

    cancelable = apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:]).sink { completion in
      switch completion {
        case .finished: break
        case .failure(let error): XCTAssertEqual(error, UVError.noData("No data for HTTP Code 404"))
      }
    } receiveValue: { forecast in
      XCTFail("Should not trigger success")
    }

    verify(sessionMock).loadData(from: any())
    verifyNoMoreInteractions(sessionMock)
  }

  func testLoadDataFailureJSONDecode() {
    let wrongData = "{id: 12}".data(using: .utf8)!
    let expectedURLResponse = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let expectedPublisher = Just((data: wrongData, response: expectedURLResponse as URLResponse)).setFailureType(to: URLError.self).eraseToAnyPublisher()

    stub(sessionMock) { stub in
      when(stub).loadData(from: any()).thenReturn(expectedPublisher)
    }

    cancelable = apiWorker.request(for: Forecast.self, at: expectedURL, method: .get, parameters: [:]).sink { completion in
      switch completion {
        case .finished: break
        case .failure(let error): XCTAssertEqual(error, UVError.couldNotDecodeJSON)
      }
    } receiveValue: { forecast in
      XCTFail("Should not trigger success")
    }

    verify(sessionMock).loadData(from: any())
    verifyNoMoreInteractions(sessionMock)
  }
  
}

