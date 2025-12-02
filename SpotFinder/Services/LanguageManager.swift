//
//  LanguageManager.swift
//  SpotFinder
//
//  Language management for in-app language switching
//

import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .french: return "🇫🇷"
        }
    }
}

/// Observable class to manage app language preferences
@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "AppLanguage"
    
    /// Current selected language
    var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
            applyLanguage()
        }
    }
    
    private init() {
        // Load saved language or use system language
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Default to system language if supported, otherwise English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = AppLanguage(rawValue: systemLanguage) ?? .english
        }
        applyLanguage()
    }
    
    /// Save the selected language to UserDefaults
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    /// Apply the language change to the app
    private func applyLanguage() {
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Update the bundle for localization
        Bundle.setLanguage(currentLanguage.rawValue)
    }
    
    /// Get localized string for the current language
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

// MARK: - Bundle Extension for Language Switching

private var bundleKey: UInt8 = 0

extension Bundle {
    /// Set the app's language programmatically
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LanguageBundle.self)
        }
        objc_setAssociatedObject(
            Bundle.main,
            &bundleKey,
            Bundle.main.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

/// Custom bundle class that returns localized strings from the selected language bundle
private class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}
