//
//  APIExecutor.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 27/06/2019.
//  Copyright © 2019 Thomas Guilleminot. All rights reserved.
//

import Foundation

protocol TaskExecutable: Codable {}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

protocol APIWorker {
  func request<T: TaskExecutable>(for type: T.Type, at url: URL, method: HTTPMethod, parameters: [String: Any], completion: @escaping (Result<T, UVError>) -> Void)
}

class APIWorkerImpl: APIWorker {
  
  private let session: URLSession
  
  init(with configuration: URLSessionConfiguration) {
    self.session = URLSession(configuration: configuration)
  }
  
  func request<T: TaskExecutable>(for type: T.Type, at url: URL, method: HTTPMethod, parameters: [String: Any], completion: @escaping (Result<T, UVError>) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let dataTask = self.session.dataTask(with: url) { data, _, error in
      guard error == nil else {
        completion(.failure(.customError(error?.localizedDescription ?? "Unknown error")))
        return
      }
      
      guard let jsonData = data else {
        completion(.failure(.noData))
        return
      }
      
      do {
        let resources = try JSONDecoder().decode(type, from: jsonData)
        completion(.success(resources))
      } catch {
        completion(.failure(.couldNotDecodeJSON))
      }
    }
    dataTask.resume()
  }
  
}
