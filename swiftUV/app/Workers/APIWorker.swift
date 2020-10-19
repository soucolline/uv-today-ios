//
//  APIExecutor.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 27/06/2019.
//  Copyright © 2019 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Combine

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

protocol APIWorker {
  func request<T: TaskExecutable>(for type: T.Type, at url: URL, method: HTTPMethod, parameters: [String: Any]) -> AnyPublisher<T, UVError>
}

class APIWorkerImpl: APIWorker {
  
  private let session: NetworkSession
  
  init(with session: NetworkSession) {
    self.session = session
  }

  func request<T: TaskExecutable>(for type: T.Type, at url: URL, method: HTTPMethod, parameters: [String: Any]) -> AnyPublisher<T, UVError> {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

    return self.session.loadData(from: url)
      .tryMap { output in
        guard let response = output.response as? HTTPURLResponse else {
          throw UVError.urlNotValid
        }

        switch response.statusCode {
          case 200:
            return output.data
          default:
            throw UVError.noData("No data for HTTP Code \(response.statusCode)")
        }
      }
      .decode(type: type, decoder: JSONDecoder())
      .mapError { error in
        switch error {
          case is UVError:
            return (error as? UVError) ?? .customError(error.localizedDescription)
          case is Swift.DecodingError:
            return .couldNotDecodeJSON
          default:
            return .customError(error.localizedDescription)
        }
      }
      .eraseToAnyPublisher()
  }
  
}
