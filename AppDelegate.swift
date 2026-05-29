import SwiftUI

@main
struct RPGGameApp: App {
    @State private var isAppActive = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    isAppActive = false
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    isAppActive = true
                }
        }
    }
}

// App Configuration
class AppConfiguration {
    static let shared = AppConfiguration()
    
    let appName = "Epic RPG Quest"
    let appVersion = "1.0.0"
    let bundleIdentifier = "com.yourcompany.rpggame"
    let minimumIOSVersion = "15.0"
    
    // Game Settings
    let defaultDifficulty = "Normal"
    let enableAnalytics = true
    let enableCrashReporting = true
    
    // Localization
    let supportedLanguages = ["en", "es", "fr", "de"]
    let defaultLanguage = "en"
}

// Logging Service
class LoggingService {
    static let shared = LoggingService()
    private var logBuffer: [String] = []
    
    func log(_ message: String, level: LogLevel = .info) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)"
        logBuffer.append(logEntry)
        
        #if DEBUG
        print(logEntry)
        #endif
        
        if logBuffer.count > 1000 {
            logBuffer.removeFirst(500)
        }
    }
    
    func getLog() -> [String] {
        return logBuffer
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}

// Data Storage Service
class DataStorageService {
    static let shared = DataStorageService()
    
    private let defaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    func savePlayer(_ player: Player) {
        if let encoded = try? JSONEncoder().encode(player) {
            defaults.set(encoded, forKey: "player_data")
            LoggingService.shared.log("Player data saved: \(player.name)", level: .info)
        }
    }
    
    func loadPlayer() -> Player? {
        if let data = defaults.data(forKey: "player_data"),
           let player = try? JSONDecoder().decode(Player.self, from: data) {
            LoggingService.shared.log("Player data loaded: \(player.name)", level: .info)
            return player
        }
        return nil
    }
    
    func deletePlayerData() {
        defaults.removeObject(forKey: "player_data")
        LoggingService.shared.log("Player data deleted", level: .info)
    }
    
    func getSaveDirectory() -> URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

// Analytics Service
class AnalyticsService {
    static let shared = AnalyticsService()
    
    func trackEvent(_ event: String, properties: [String: Any]? = nil) {
        guard AppConfiguration.shared.enableAnalytics else { return }
        LoggingService.shared.log("Analytics Event: \(event)", level: .info)
    }
    
    func trackGameStart(characterName: String, characterClass: String) {
        trackEvent("game_start", properties: [
            "character_name": characterName,
            "character_class": characterClass
        ])
    }
    
    func trackGameEnd(level: Int, experience: Int, gold: Int) {
        trackEvent("game_end", properties: [
            "level": level,
            "experience": experience,
            "gold": gold
        ])
    }
    
    func trackBattle(enemyName: String, playerWon: Bool) {
        trackEvent("battle_completed", properties: [
            "enemy": enemyName,
            "won": playerWon
        ])
    }
}

// Crash Reporting Service
class CrashReportingService {
    static let shared = CrashReportingService()
    
    func reportException(_ exception: NSException) {
        guard AppConfiguration.shared.enableCrashReporting else { return }
        LoggingService.shared.log("Exception: \(exception.name) - \(exception.reason ?? "Unknown")", level: .error)
    }
    
    func reportError(_ error: Error) {
        LoggingService.shared.log("Error: \(error.localizedDescription)", level: .error)
    }
}

// Network Service (for future multiplayer features)
class NetworkService {
    static let shared = NetworkService()
    private let session = URLSession.shared
    
    func fetchGameData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Placeholder for future network calls
        completion(.success([:]))
    }
}

// App Delegate Setup
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LoggingService.shared.log("App launched", level: .info)
        
        // Initialize crash reporting
        setupCrashReporting()
        
        // Set up appearance
        setupAppearance()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        LoggingService.shared.log("App became active", level: .debug)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        LoggingService.shared.log("App resigned active", level: .debug)
    }
    
    private func setupCrashReporting() {
        NSSetUncaughtExceptionHandler { exception in
            CrashReportingService.shared.reportException(exception)
        }
    }
    
    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.cyan]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
