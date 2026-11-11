import ComposableArchitecture
import LocationManager
import Models
import UIKit
import UVClient

@Reducer
public struct UVFeature {
  @ObservableState
  public struct State: Equatable {
    var attribution: AttributionResponse?
    var cityName = "loading"
    var errorText: String?
    var isLocationRefused = false
    var loading: Loading?
    var location: Models.Location?
    var uvIndex: Index = 0

    public init() {}
  }

  public enum Action: Sendable {
    case attributionResponse(AttributionResponse)
    case errorDismissed
    case locationResponse(Result<Models.Location, LocationError>)
    case openSettingsButtonTapped
    case refreshButtonTapped
    case sceneBecameActive
    case sceneEnteredBackground
    case screenDisappeared
    case screenTask
    case weatherFailed(String)
    case weatherResponse(index: Index, cityName: String)
  }

  enum Loading: Equatable {
    case location
    case weather
  }

  private enum CancelID {
    case location
    case weather
  }

  @Dependency(LocationClient.self) private var locationClient
  @Dependency(\.openURL) private var openURL
  @Dependency(UVClientKey.self) private var uvClient

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .attributionResponse(let attribution):
        state.attribution = attribution
        return .none

      case .errorDismissed:
        state.errorText = nil
        return .none

      case .locationResponse(.success(let location)):
        state.isLocationRefused = false
        state.location = location
        state.loading = .weather
        return fetchWeather(at: location)

      case .locationResponse(.failure(let error)):
        state.loading = nil
        state.location = nil
        state.isLocationRefused = error == .denied || error == .restricted
        state.errorText = state.isLocationRefused
          ? "app.error.localisationDisabled".localized
          : "app.error.couldNotLocalise".localized
        return .none

      case .openSettingsButtonTapped:
        return .run { [openURL] _ in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            await openURL(url)
          }
        }

      case .refreshButtonTapped:
        guard state.loading == nil, !state.isLocationRefused else { return .none }
        guard let location = state.location else {
          state.errorText = "app.error.couldNotLocalise".localized
          return .none
        }
        state.errorText = nil
        state.loading = .weather
        return fetchWeather(at: location)

      case .sceneBecameActive:
        guard state.loading == nil else { return .none }
        state.errorText = nil
        state.loading = .location
        return .run { [locationClient] send in
          do {
            let location = try await locationClient.currentLocation()
            await send(.locationResponse(.success(location)))
          } catch is CancellationError {
            return
          } catch {
            await send(.locationResponse(.failure(error as? LocationError ?? .unavailable)))
          }
        }
        .cancellable(id: CancelID.location)

      case .sceneEnteredBackground, .screenDisappeared:
        state.loading = nil
        return .merge(.cancel(id: CancelID.location), .cancel(id: CancelID.weather))

      case .screenTask:
        guard state.attribution == nil else { return .none }
        return .run { [uvClient] send in
          if let attribution = try? await uvClient.fetchWeatherKitAttribution() {
            await send(.attributionResponse(attribution))
          }
        }

      case .weatherFailed(let message):
        state.loading = nil
        state.errorText = message
        state.cityName = "app.label.unknown".localized
        state.uvIndex = 0
        return .none

      case .weatherResponse(let index, let cityName):
        state.loading = nil
        state.uvIndex = index
        state.cityName = cityName
        return .none
      }
    }
  }

  private func fetchWeather(at location: Models.Location) -> Effect<Action> {
    .run { [uvClient] send in
      do {
        async let index = uvClient.fetchUVIndex(
          request: UVClientRequest(lat: location.latitude, long: location.longitude)
        )
        async let cityName = uvClient.fetchCityName(location: location)
        let (indexValue, cityNameValue) = try await (index, cityName)
        await send(.weatherResponse(index: indexValue, cityName: cityNameValue))
      } catch is CancellationError {
        return
      } catch {
        await send(.weatherFailed((error as? UVError)?.localizedDescription ?? error.localizedDescription))
      }
    }
    .cancellable(id: CancelID.weather)
  }
}
