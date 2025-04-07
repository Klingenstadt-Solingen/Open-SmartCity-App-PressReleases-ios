//
//  UserDefaults+DeveloperOptions.swift
//  OSCAPressReleases
//
//  Created by Stephan Breidenbach on 30.01.23.
//

import Foundation

extension OSCAPressReleases {
  public var isDeveloperOptionsEnabled: Bool {
    self.userDefaults.bool(forKey: "Settings_isDeveloperOptionsEnabled")
  }// end
}// end extension public struct OSCAPressReleases
