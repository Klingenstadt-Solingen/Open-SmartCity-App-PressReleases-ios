//
//  OSCAPressReleaseImageData.swift
//  OSCAPressReleases
//
//  Created by Ömer Kurutay on 06.04.22.
//

import OSCAEssentials
import Foundation

public struct OSCAPressReleaseImageData: OSCAImageData {
  
  public var objectId: String?
  public var imageData: Data?
  
  public init(objectId: String, imageData: Data) {
    self.objectId = objectId
    self.imageData = imageData
  }
  
  public static func < (lhs: OSCAPressReleaseImageData, rhs: OSCAPressReleaseImageData) -> Bool {
    let lhsImageData = lhs.imageData
    let rhsImageData = rhs.imageData
    if nil != lhsImageData {
      if nil != rhsImageData {
        return lhsImageData!.count < rhsImageData!.count
      } else {
        return false
      }
    } else {
      if nil != rhsImageData {
        return false
      } else {
        return true
      }
    }
  }
}

extension OSCAPressReleaseImageData: Codable {}
extension OSCAPressReleaseImageData: Hashable {}
extension OSCAPressReleaseImageData: Equatable {}
