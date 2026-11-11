import ComposableArchitecture
import Foundation
import LocationManager
import Models
import Testing
import UIKit
import UVClient

@testable import AppFeature

@MainActor
struct UVFeatureTests {
  private static let paris = Models.Location(latitude: 48.86, longitude: 2.35)

  @Test func activeSceneLoadsWeatherForCurrentLocation() async {
    let location = Self.paris
    let store = TestStore(initialState: UVFeature.State()) {
      UVFeature()
    } withDependencies: {
      $0[LocationClient.self].currentLocation = { location }
      $0[UVClientKey.self] = WeatherStub(location: location)
    }

    await store.send(.sceneBecameActive) {
      $0.loading = .location
    }
    await store.receive(\.locationResponse) {
      $0.location = location
      $0.loading = .weather
    }
    await store.receive(\.weatherResponse) {
      $0.cityName = "Paris"
      $0.loading = nil
      $0.uvIndex = 6
    }
  }

  @Test(arguments: [LocationError.denied, .restricted, .unavailable])
  func locationFailureClearsLoading(error: LocationError) async {
    let refused = error != .unavailable
    let store = TestStore(initialState: UVFeature.State()) {
      UVFeature()
    } withDependencies: {
      $0[LocationClient.self].currentLocation = { throw error }
    }

    await store.send(.sceneBecameActive) {
      $0.loading = .location
    }
    await store.receive(\.locationResponse) {
      $0.loading = nil
      $0.isLocationRefused = refused
      $0.errorText = refused
        ? "app.error.localisationDisabled".localized
        : "app.error.couldNotLocalise".localized
    }
    await store.send(.errorDismissed) {
      $0.errorText = nil
    }
    await store.finish()
  }

  @Test func refreshReusesTheLastLocation() async {
    let location = Self.paris
    var state = UVFeature.State()
    state.location = location
    let store = TestStore(initialState: state) {
      UVFeature()
    } withDependencies: {
      $0[UVClientKey.self] = WeatherStub(location: location)
    }

    await store.send(.refreshButtonTapped) {
      $0.loading = .weather
    }
    await store.receive(\.weatherResponse) {
      $0.cityName = "Paris"
      $0.loading = nil
      $0.uvIndex = 6
    }
  }

  @Test func refreshWithoutLocationShowsAnError() async {
    let store = TestStore(initialState: UVFeature.State()) { UVFeature() }

    await store.send(.refreshButtonTapped) {
      $0.errorText = "app.error.couldNotLocalise".localized
    }
  }

  @Test func settingsButtonOpensAppSettings() async {
    let openedURLs = LockIsolated<[URL]>([])
    let store = TestStore(initialState: UVFeature.State()) {
      UVFeature()
    } withDependencies: {
      $0.openURL = OpenURLEffect { url in
        openedURLs.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.openSettingsButtonTapped).finish()
    #expect(openedURLs.value.map(\.absoluteString) == [UIApplication.openSettingsURLString])
  }

  @Test func weatherFailureClearsLoadingAndAllowsRetry() async {
    let location = Self.paris
    var state = UVFeature.State()
    state.location = location
    let store = TestStore(initialState: state) {
      UVFeature()
    } withDependencies: {
      $0[UVClientKey.self] = WeatherStub(location: location, error: .noWeatherAvailable)
    }

    await store.send(.refreshButtonTapped) {
      $0.loading = .weather
    }
    await store.receive(\.weatherFailed) {
      $0.cityName = "app.label.unknown".localized
      $0.errorText = UVError.noWeatherAvailable.localizedDescription
      $0.loading = nil
    }

    store.dependencies[UVClientKey.self] = WeatherStub(location: location)
    await store.send(.refreshButtonTapped) {
      $0.errorText = nil
      $0.loading = .weather
    }
    await store.receive(\.weatherResponse) {
      $0.cityName = "Paris"
      $0.loading = nil
      $0.uvIndex = 6
    }
  }

  @Test func enteringBackgroundCancelsPendingLocation() async {
    let clock = TestClock()
    let location = Self.paris
    let store = TestStore(initialState: UVFeature.State()) {
      UVFeature()
    } withDependencies: {
      $0[LocationClient.self].currentLocation = {
        try await clock.sleep(for: .seconds(60))
        return location
      }
    }

    await store.send(.sceneBecameActive) {
      $0.loading = .location
    }
    await store.send(.sceneBecameActive)
    await store.send(.sceneEnteredBackground) {
      $0.loading = nil
    }
    await store.finish()
  }

  @Test func screenTaskLoadsWeatherAttributionOnce() async {
    let attribution = AttributionResponse(
      logo: URL(string: "https://example.com/weather-logo.png")!,
      link: URL(string: "https://example.com/weather-sources")!
    )
    let location = Self.paris
    let store = TestStore(initialState: UVFeature.State()) {
      UVFeature()
    } withDependencies: {
      $0[UVClientKey.self] = WeatherStub(location: location, attribution: attribution)
    }

    await store.send(.screenTask)
    await store.receive(\.attributionResponse) {
      $0.attribution = attribution
    }
    await store.send(.screenTask)
    await store.finish()
  }
}

private struct WeatherStub: UVClient {
  let location: Models.Location
  var error: UVError?
  var attribution: AttributionResponse?

  func fetchUVIndex(request: UVClientRequest) async throws -> Index {
    #expect(request.lat == location.latitude)
    #expect(request.long == location.longitude)
    if let error { throw error }
    return 6
  }

  func fetchCityName(location: Models.Location) async throws -> String {
    #expect(location == self.location)
    return "Paris"
  }

  func fetchWeatherKitAttribution() async throws -> AttributionResponse {
    guard let attribution else {
      Issue.record("Unexpected attribution request")
      throw UVError.noAttributionAvailable
    }
    return attribution
  }
}
