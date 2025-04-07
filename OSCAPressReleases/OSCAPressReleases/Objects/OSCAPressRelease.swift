//
//  OSCAPressRelease.swift
//  OSCAPressRelease
//
//  Created by Mammut Nithammer on 19.01.22.
//

import Foundation
import OSCAEssentials

/// Object representing a press release
public struct OSCAPressRelease: OSCAParseClassObject, Equatable {
  /// ObjectId of the press release
  public private(set) var objectId: String?
  /// When the object was created.
  public private(set) var createdAt: Date?
  /// When the object was last updated.
  public private(set) var updatedAt: Date?
  /// Date of the press release
  public var date: Date?
  /// Url to the web version of the press release
  public var guid: String?
  /// Url to the web version of the press release
  public var url: String?
  /// Title of the press release
  public var title: String?
  /// Summary or preview of the press release
  public var summary: String?
  /// Category of the press release
  public var category: String?
  /// Content of the press release
  public var content: String?
  /// Deeplink to navigate to the press release detail screen
  public var deepLink: String?
  /// Url of the press release image
  public var imageUrl: String?
  /// Reading time of the press release in minutes
  public var readingTime: Int?
}

extension OSCAPressRelease {
  /// Parse class name
  public static var parseClassName : String { return "PressRelease" }
}// end extension OSCAPressRelease
