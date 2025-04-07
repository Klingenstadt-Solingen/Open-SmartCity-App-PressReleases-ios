//
//  OSCARequestResource+PressReleases.swift
//  OSCAPressReleases
//
//  Created by Mammut Nithammer on 19.01.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// ClassReqestRessource for press releases
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/PressRelease'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use OSCAClassRequestResource
  static func pressRelease(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource {
    let parseClass = OSCAPressRelease.parseClassName
    return OSCAClassRequestResource(baseURL: baseURL, parseClass: parseClass, parameters: query, headers: headers)
  }
}
