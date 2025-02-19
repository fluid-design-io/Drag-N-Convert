import Foundation

class StateManager {
  private let defaults = UserDefaults.standard
  private let stateKey = "app_state"

  func loadState() -> AppState {
    guard let data = defaults.data(forKey: stateKey),
      let state = try? JSONDecoder().decode(AppState.self, from: data)
    else {
      return AppState()
    }
    return state
  }

  func saveState(_ state: AppState) {
    guard let data = try? JSONEncoder().encode(state) else {
      return
    }
    defaults.set(data, forKey: stateKey)
  }
}
