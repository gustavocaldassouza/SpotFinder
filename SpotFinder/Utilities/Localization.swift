//
//  Localization.swift
//  SpotFinder
//
//  String localization utilities
//

import Foundation

// MARK: - String Extension for Localization

extension String {
    /// Returns the localized string for the current key
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns the localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Localization Keys

/// Type-safe localization keys to avoid typos
enum L10n {
    // MARK: - Common
    enum Common {
        static let done = "common.done".localized
        static let cancel = "common.cancel".localized
        static let ok = "common.ok".localized
        static let error = "common.error".localized
        static let submit = "common.submit".localized
        static let loading = "common.loading".localized
        static let remove = "common.remove".localized
    }
    
    // MARK: - App
    enum App {
        static let name = "app.name".localized
        static let tagline = "app.tagline".localized
    }
    
    // MARK: - Map
    enum Map {
        static let searchPlaceholder = "map.searchPlaceholder".localized
        static let reportSpot = "map.reportSpot".localized
        static let spotAvailable = "map.spotAvailable".localized
        static let spotTaken = "map.spotTaken".localized
        static let addressNotFound = "map.addressNotFound".localized
        static let searchFailed = "map.searchFailed".localized
        static let locationFailed = "map.locationFailed".localized
    }
    
    // MARK: - Report
    enum Report {
        static let title = "report.title".localized
        static let status = "report.status".localized
        static let statusHeader = "report.statusHeader".localized
        static let spotAvailable = "report.spotAvailable".localized
        static let spotTaken = "report.spotTaken".localized
        static let locationHeader = "report.locationHeader".localized
        static let locationSource = "report.locationSource".localized
        static let currentLocation = "report.currentLocation".localized
        static let mapLocation = "report.mapLocation".localized
        static let searchAddress = "report.searchAddress".localized
        static let gettingLocation = "report.gettingLocation".localized
        static let usingCurrentLocation = "report.usingCurrentLocation".localized
        static let usingMapLocation = "report.usingMapLocation".localized
        static let usingSearchedLocation = "report.usingSearchedLocation".localized
        static let searchForAddress = "report.searchForAddress".localized
        static let detailsHeader = "report.detailsHeader".localized
        static let descriptionPlaceholder = "report.descriptionPlaceholder".localized
        static let descriptionFooter = "report.descriptionFooter".localized
        static let addressPlaceholder = "report.addressPlaceholder".localized
        static let address = "report.address".localized
        static let latitude = "report.latitude".localized
        static let longitude = "report.longitude".localized
        static let unableToGetLocation = "report.unableToGetLocation".localized
        static let failedToSubmit = "report.failedToSubmit".localized
        static let addressNotFound = "report.addressNotFound".localized
        static let addressSearchFailed = "report.addressSearchFailed".localized
    }
    
    // MARK: - Settings
    enum Settings {
        static let title = "settings.title".localized
        static let accountHeader = "settings.accountHeader".localized
        static let profile = "settings.profile".localized
        static let permissionsHeader = "settings.permissionsHeader".localized
        static let locationAccess = "settings.locationAccess".localized
        static let openSettings = "settings.openSettings".localized
        static let locationFooter = "settings.locationFooter".localized
        static let aboutHeader = "settings.aboutHeader".localized
        static let version = "settings.version".localized
        static let build = "settings.build".localized
        static let resourcesHeader = "settings.resourcesHeader".localized
        static let github = "settings.github".localized
        static let support = "settings.support".localized
        static let languageHeader = "settings.languageHeader".localized
        static let language = "settings.language".localized
        static let languageFooter = "settings.languageFooter".localized
        static let restartRequired = "settings.restartRequired".localized
        static let restartMessage = "settings.restartMessage".localized
    }
    
    // MARK: - Permission
    enum Permission {
        static let notDetermined = "permission.notDetermined".localized
        static let restricted = "permission.restricted".localized
        static let denied = "permission.denied".localized
        static let always = "permission.always".localized
        static let whileUsing = "permission.whileUsing".localized
    }
    
    // MARK: - Favorites
    enum Favorites {
        static let title = "favorites.title".localized
        static let loading = "favorites.loading".localized
        static let emptyTitle = "favorites.empty.title".localized
        static let emptyMessage = "favorites.empty.message".localized
        static let expired = "favorites.expired".localized
        static let availableSpot = "favorites.availableSpot".localized
        static let takenSpot = "favorites.takenSpot".localized
    }
    
    // MARK: - Spot Detail
    enum SpotDetail {
        static let title = "spotDetail.title".localized
        static let available = "spotDetail.available".localized
        static let taken = "spotDetail.taken".localized
        static let reported = "spotDetail.reported".localized
        static let expires = "spotDetail.expires".localized
        static let description = "spotDetail.description".localized
        static let accuracy = "spotDetail.accuracy".localized
        static let location = "spotDetail.location".localized
        static let markNotAvailable = "spotDetail.markNotAvailable".localized
        static let accurate = "spotDetail.accurate".localized
        static let inaccurate = "spotDetail.inaccurate".localized
        static let thanks = "spotDetail.thanks".localized
        static let alreadyRated = "spotDetail.alreadyRated".localized
        static let alreadyRatedMessage = "spotDetail.alreadyRatedMessage".localized
        static let ratingError = "spotDetail.ratingError".localized
        static let ratingSuccess = "spotDetail.ratingSuccess".localized
        static let updatedNotAvailable = "spotDetail.updatedNotAvailable".localized
        
        static func ratingsCount(_ count: Int) -> String {
            if count == 1 {
                return "spotDetail.oneRating".localized
            }
            return "spotDetail.multipleRatings".localized(with: count)
        }
    }
    
    // MARK: - Sign In
    enum SignIn {
        static let title = "signIn.title".localized
        static let email = "signIn.email".localized
        static let password = "signIn.password".localized
        static let button = "signIn.button".localized
        static let noAccount = "signIn.noAccount".localized
        static let signUp = "signIn.signUp".localized
    }
    
    // MARK: - Sign Up
    enum SignUp {
        static let title = "signUp.title".localized
        static let subtitle = "signUp.subtitle".localized
        static let firstName = "signUp.firstName".localized
        static let lastName = "signUp.lastName".localized
        static let email = "signUp.email".localized
        static let password = "signUp.password".localized
        static let confirmPassword = "signUp.confirmPassword".localized
        static let button = "signUp.button".localized
        static let passwordMismatch = "signUp.passwordMismatch".localized
    }
    
    // MARK: - Profile
    enum Profile {
        static let title = "profile.title".localized
        static let name = "profile.name".localized
        static let email = "profile.email".localized
        static let memberSince = "profile.memberSince".localized
        static let signOut = "profile.signOut".localized
    }
    
    // MARK: - Error
    enum Error {
        static let defaultMessage = "error.defaultMessage".localized
    }
    
    // MARK: - API Error
    enum APIError {
        static let invalidURL = "apiError.invalidURL".localized
        static let invalidResponse = "apiError.invalidResponse".localized
        static let noData = "apiError.noData".localized
        static let unauthorized = "apiError.unauthorized".localized
        static let unknown = "apiError.unknown".localized
        
        static func networkError(_ description: String) -> String {
            return "apiError.networkError".localized(with: description)
        }
        
        static func decodingError(_ description: String) -> String {
            return "apiError.decodingError".localized(with: description)
        }
        
        static func serverError(_ code: Int, _ message: String) -> String {
            return "apiError.serverError".localized(with: code, message)
        }
    }
}
