import CoreLocation
import Models

// Core Location calls the delegate on the run loop where its manager was created.
@MainActor
final class LocationRequest: NSObject, @preconcurrency CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var continuation: CheckedContinuation<Models.Location, any Error>?
  private var requestedFix = false

  func location() async throws -> Models.Location {
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        guard !Task.isCancelled else {
          continuation.resume(throwing: CancellationError())
          return
        }
        self.continuation = continuation
        manager.delegate = self
        if manager.authorizationStatus == .notDetermined {
          manager.requestWhenInUseAuthorization()
        } else {
          locationManagerDidChangeAuthorization(manager)
        }
      }
    } onCancel: {
      Task { @MainActor in
        self.finish(.failure(CancellationError()))
      }
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard continuation != nil else { return }
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      guard !requestedFix else { return }
      requestedFix = true
      manager.requestLocation()
    case .denied:
      finish(.failure(LocationError.denied))
    case .restricted:
      finish(.failure(LocationError.restricted))
    case .notDetermined:
      break
    @unknown default:
      finish(.failure(LocationError.unavailable))
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let coordinate = locations.last?.coordinate else {
      finish(.failure(LocationError.unavailable))
      return
    }
    finish(.success(Models.Location(latitude: coordinate.latitude, longitude: coordinate.longitude)))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    let failure: LocationError
    switch manager.authorizationStatus {
    case .denied: failure = .denied
    case .restricted: failure = .restricted
    default: failure = .unavailable
    }
    finish(.failure(failure))
  }

  private func finish(_ result: Result<Models.Location, any Error>) {
    guard let continuation else { return }
    self.continuation = nil
    manager.delegate = nil
    manager.stopUpdatingLocation()
    continuation.resume(with: result)
  }
}
