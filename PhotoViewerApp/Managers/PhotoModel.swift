//
//  PhotoModel.swift
//  PhotoViewerApp
//
//  Created by 縣美早 on 2019/04/13.
//  Copyright © 2019 縣美早. All rights reserved.
//

import UIKit
import Foundation

struct PhotoModel: Codable {
   
    let total: Int?
    let totalHits: Int?
    let hits: [Hits?]
    
}

struct Hits: Codable {
    
    let id: Int?
    let pageURL: URL?
    let type: String?
    let tags: String?
    let previewURL: URL?
    let previewWidth: Int?
    let previewHeight: Int?
    let webformatURL: URL?
    let webformatWidth: Int?
    let webformatHeight: Int?
    let largeImageURL: URL?
    //let fullHDURL: URL?
    //let imageURL: URL?
    let imageWidth: Int?
    let imageHeight: Int?
    let imageSize: Int?
    let views: Int?
    let downloads: Int?
    let favorites: Int?
    let likes: Int?
    let comments: Int?
    //let user_id: Int?
    //let user: String?
    //let userImageURL: URL?
    
    
}
