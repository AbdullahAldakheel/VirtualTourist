//
//  RJson.swift
//  VirtualTourist
//
//  Created by Abdullah Aldakhiel on 31/01/2019.
//  Copyright © 2019 Abdullah Aldakhiel. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: PhotosS
}

struct PhotosS: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
