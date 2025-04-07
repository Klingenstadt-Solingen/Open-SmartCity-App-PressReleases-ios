//
//  OSCAImageFileDataRequestResource.swift
//  OSCAPressReleases
//
//  Created by Ömer Kurutay on 01.04.22.
//  Reviewed by Stephan Breidenbach on 01.02.23
//

import Foundation
import OSCAEssentials
import OSCANetworkService

extension OSCAImageDataRequestResource {
  /// OSCAImageFileDataRequestResource for press releases image
  /// - Parameters:
  ///    - objectId: The id of a PressRelease
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: A ready to use OSCAImageFileDataRequestResource
  static func pressReleaseImageData(objectId: String,
                                    baseURL: URL,
                                    fileName: String,
                                    mimeType: String) -> OSCAImageDataRequestResource<OSCAPressReleaseImageData> {
    return OSCAImageDataRequestResource<OSCAPressReleaseImageData>(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
  }// end static func pressReleaseImageData
}// end extension OSCAImageDataRequestResource
