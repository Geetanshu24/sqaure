//
//  PropertyVideo.swift
//  square_yards
//

import Foundation

struct PropertyVideo: Identifiable, Decodable, Equatable {
    let id: String
    let url: URL
    let thumbnailURL: URL
    let tag: String
    let title: String
    let location: String
    let developerName: String?
    let expertName: String?
    let viewCount: Int

    var attributedSubtitle: String {
        if let developerName, developerName.isEmpty == false {
            return developerName
        }

        if let expertName, expertName.isEmpty == false {
            return "By \(expertName)"
        }

        return "Square Yards Verified"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnailURL = "thumbnailUrl"
        case tag
        case title
        case location
        case developerName
        case expertName
        case viewCount
    }
}
