//
//  UVServiceTests.swift
//  swiftUVTests
//
//  Created by Thomas Guilleminot on 19/10/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import XCTest
import Cuckoo
import Combine

@testable import swiftUV

class UVServiceTests: XCTestCase {

  private var mockApiWorker: MockAPIWorker!
  private var mockURLFactory: MockURLFactory!

  private var uvService: UVService!
  private var cancelable: AnyCancellable?

  private let expectedForecast = Forecast(lat: 12, lon: 13, dateIso: "sdksja", date: 21345, value: 4.3)
  private let expectedLocation = Location(latitude: 12, longitude: 13, city: "Paris")

  override func setUp() {
    self.mockApiWorker = MockAPIWorker()
    self.mockURLFactory = MockURLFactory(with: "123456")

    self.uvService = UVServiceImpl(with: mockApiWorker, urlFactory: mockURLFactory)
  }

  func testGetUVSuccess() {
    let expectedValue = 4
    let expectedPublisher = Just(expectedForecast).setFailureType(to: UVError.self).eraseToAnyPublisher()

    stub(mockURLFactory) { stub in
      when(stub).createUVURL(lat: any(), lon: any()).thenReturn(URL(string: "https://fake.com")!)
    }

    stub(mockApiWorker) { stub in
      when(stub).request(for: any(), at: any(), method: any(), parameters: any()).thenReturn(expectedPublisher)
    }

    cancelable = uvService.getUVIndex(from: expectedLocation).sink { completion in
      switch completion {
        case .finished: break
        case .failure: XCTFail("Should not fail")
      }
    } receiveValue: { value in
      XCTAssertEqual(value, expectedValue)
    }
  }

  func testGetUVFailure() {
    let expectedError = UVError.couldNotDecodeJSON
    let expectedPublisher: AnyPublisher<Forecast, UVError> = Result.failure(expectedError).publisher.eraseToAnyPublisher()

    stub(mockURLFactory) { stub in
      when(stub).createUVURL(lat: any(), lon: any()).thenReturn(URL(string: "https://fake.com")!)
    }

    stub(mockApiWorker) { stub in
      when(stub).request(for: any(), at: any(), method: any(), parameters: any()).thenReturn(expectedPublisher)
    }

    cancelable = uvService.getUVIndex(from: expectedLocation).sink{ completion in
      switch completion {
        case .finished: break
        case .failure(let error): XCTAssertEqual(error, expectedError)
      }
    } receiveValue: { _ in
      XCTFail("Should not succeed")
    }
  }

}
