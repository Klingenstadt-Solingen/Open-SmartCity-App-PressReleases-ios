//
//  UserDefaults.swift
//  OSCAPressReleases
//
//  Created by Ömer Kurutay on 06.06.23.
//

import Foundation

// MARK: Push
extension UserDefaults {
  public func setOSCAPressReleasesPush(notification isPushing: Bool) {
    self.set(isPushing, forKey: OSCAPressReleases.Keys.userDefaultsPressReleasesPush.rawValue)
    NotificationCenter.default.post(name: .pressReleasesPushDidChange, object: nil, userInfo: nil)
  }
  
  public func isOSCAPressReleasesPushingNotification() -> Bool {
    self.bool(forKey: OSCAPressReleases.Keys.userDefaultsPressReleasesPush.rawValue)
  }
}
