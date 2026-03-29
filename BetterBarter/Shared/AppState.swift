import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isTabBarHidden: Bool = false
    
    static let shared = AppState()
}
