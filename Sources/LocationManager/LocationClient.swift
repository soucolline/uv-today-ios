import Dependencies
import Models

package struct LocationClient: Sendable {
  package var currentLocation: @MainActor @Sendable () async throws -> Models.Location
}

extension LocationClient: DependencyKey {
  package static var liveValue: Self {
    Self(currentLocation: { try await LocationRequest().location() })
  }

  package static var testValue: Self {
    Self(currentLocation: unimplemented("LocationClient.currentLocation"))
  }
}

public enum LocationError: Error, Equatable {
  case denied
  case restricted
  case unavailable
}
