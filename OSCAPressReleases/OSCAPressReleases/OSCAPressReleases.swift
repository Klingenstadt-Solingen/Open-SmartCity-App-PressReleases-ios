//
//  OSCAPressReleases.swift
//  OSCAPressReleases
//
//  Created by Ömer Kurutay on 19.01.22.
//  Reviewed by Stephan Breidenbach on 20.06.2022
//
import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCAPressReleasesDependencies {
  let appStoreURL: URL?
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let dataCache = NSCache<NSString, NSData>()
  let analyticsModule: OSCAAnalyticsModule?

  public init(appStoreURL: URL? = nil,
              networkService: OSCANetworkService,
              userDefaults: UserDefaults,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.appStoreURL = appStoreURL
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.analyticsModule = analyticsModule
  } // end public memberwise init
} // end public struct OSCAPressReleasesDependencies

/// Module to handle press releases
public struct OSCAPressReleases: OSCAModule {
  /// module DI container
  var moduleDIContainer: OSCAPressReleasesDIContainer!

  let transformError: (OSCANetworkError) -> OSCAPressReleaseError = { networkError in
    switch networkError {
    case OSCANetworkError.invalidResponse:
      return OSCAPressReleaseError.networkInvalidResponse
    case OSCANetworkError.invalidRequest:
      return OSCAPressReleaseError.networkInvalidRequest
    case let OSCANetworkError.dataLoadingError(statusCode: code, data: data):
      return OSCAPressReleaseError.networkDataLoading(statusCode: code, data: data)
    case let OSCANetworkError.jsonDecodingError(error: error):
      return OSCAPressReleaseError.networkJSONDecoding(error: error)
    case OSCANetworkError.isInternetConnectionError:
      return OSCAPressReleaseError.networkIsInternetConnectionFailure
    } // end switch case
  } // end let transformError
  /// Moduleversion
  public var version: String = "1.0.4"
  /// Bundle prefix of the module
  public var bundlePrefix: String = "de.osca.pressreleases"

  private var networkService: OSCANetworkService
  
  public private(set) var appStoreURL: URL?

  public private(set) var userDefaults: UserDefaults
  
  public private(set) var dataCache: NSCache<NSString, NSData>
  
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  /**
   create module and inject module dependencies

   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCAPressReleases.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCAPressReleasesDependencies) -> OSCAPressReleases {
    var module: OSCAPressReleases = OSCAPressReleases(appStoreURL: moduleDependencies.appStoreURL, networkService: moduleDependencies.networkService,
                                                      userDefaults: moduleDependencies.userDefaults,
                                                      dataCache: moduleDependencies.dataCache)
    module.moduleDIContainer = OSCAPressReleasesDIContainer(dependencies: moduleDependencies)

    return module
  } // end public static func create

  /// Initializes the press release module
  /// - Parameter networkService: Your configured network service
  private init(appStoreURL: URL? = nil,
               networkService: OSCANetworkService,
               userDefaults: UserDefaults,
               dataCache: NSCache<NSString, NSData>) {
    self.appStoreURL = appStoreURL  
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.dataCache = dataCache
    var bundle: Bundle?
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(identifier: bundlePrefix)
    #endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  } // end init
} // end public struct OSCAPressReleases

extension OSCAPressReleases {
  /// Downloads press releases from parse-server
  /// - Parameter limit: Limits the amount of press releases that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: An array of press releases
  public func getPressReleases(limit: Int = 1000, query: [String: String] = ["order": "-date"]) -> AnyPublisher<Result<[OSCAPressRelease], Error>, Never> {
    var parameters = query
    parameters["limit"] = "\(limit)"

    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    return networkService
      .download(OSCAClassRequestResource.pressRelease(baseURL: networkService.config.baseURL, headers: headers, query: parameters))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<[OSCAPressRelease], Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }// end public func getPressReleases

  public typealias ImageDataPublisher = AnyPublisher<OSCAPressReleaseImageData,OSCAPressReleaseError>
  /// Downloads press releases image from parse-server
  /// - Parameters:
  ///    - objectId: The id of a PressRelease
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: An image data for a press release
  public func getPressReleasesImage(objectId: String,
                                    baseURL: URL,
                                    fileName: String,
                                    mimeType: String) -> ImageDataPublisher {
    let request = OSCAImageDataRequestResource<OSCAPressReleaseImageData>.pressReleaseImageData(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
    let publisher = networkService.fetch(request)
    return publisher
      .mapError(transformError)
    // fetch events in background
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  }// end public func getPressReleasesImage
} // end extension public struct OSCAPressReleases

// MARK: - elastic search

extension OSCAPressReleases {
  public typealias OSCAPressReleasesPublisher = AnyPublisher<[OSCAPressRelease], OSCAPressReleaseError>

  /// ```console
  /// curl -vX POST 'https://parse-dev.solingen.de/functions/elastic-search' \
  ///  -H "X-Parse-Application-Id: <APP_ID>" \
  ///  -H "X-Parse-Client-Key: <CLIENT_KEY>" \
  ///  -H 'Content-Type: application/json' \
  ///  -d '{"index":"press_releases","query":"Solingen"}'
  /// ```
  public func elasticSearch(for query: String, at index: String = "press_releases", isRaw: Bool = true) -> OSCAPressReleasesPublisher {
    guard !query.isEmpty,
          !index.isEmpty
    else {
      return Empty(completeImmediately: true,
                   outputType: [OSCAPressRelease].self,
                   failureType: OSCAPressReleaseError.self).eraseToAnyPublisher()
    } // end guard
    // init cloud function parameter object
    let cloudFunctionParameter = ParseElasticSearchQuery(index: index,
                                                         query: query,
                                                         raw: isRaw)

    var publisher: AnyPublisher<[OSCAPressRelease], OSCANetworkError>
    #if MOCKNETWORK

    #else
      var headers = networkService.config.headers
      if let sessionToken = userDefaults.string(forKey: "SessionToken") {
        headers["X-Parse-Session-Token"] = sessionToken
      }

      publisher = networkService.fetch(OSCAFunctionRequestResource<ParseElasticSearchQuery>
        .elasticSearch(baseURL: networkService.config.baseURL,
                       headers: headers,
                       cloudFunctionParameter: cloudFunctionParameter))
    #endif
    return publisher
      .mapError(transformError)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  } // end public func elasticSearch for query at index
} // end extension public struct OSCAPressRealeses

// MARK: - Keys
extension OSCAPressReleases {
  /// UserDefaults object keys
  public enum Keys: String {
    case userDefaultsPressReleasesPush = "OSCAPressReleases_Push"
  }
}
