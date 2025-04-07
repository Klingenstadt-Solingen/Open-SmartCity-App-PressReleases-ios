//
//  OSCAPressReleases+DeeplinkURL.swift
//  OSCAPressReleases
//
//  Created by Stephan Breidenbach on 30.01.23.
//

import Foundation

extension OSCAPressReleases {
  /// generates an deeplink `URL` from `PressRelease` object with scheme prefix
  ///
  /// example: ``` "solingen://pressreleases/detail?object=fbzwMYb6la"```
  /// - parameter from pressRelease: `OSCAPressRelease` object
  /// - parameter with deeplinkScheme: `URL-Scheme` is the prefix before `://`
  /// - returns: optional `URL` object representation
  public func processDeeplinkURL(from pressRelease: OSCAPressRelease,
                                 with deeplinkScheme: String) -> URL? {
    guard let objectId = pressRelease.objectId else { return nil }
    return URL(string: "\(deeplinkScheme)://pressreleases/detail?object=\(objectId)")
  }// end func processDeeplinkURL from press release object
}// end extension public struct OSCAPressReleases
