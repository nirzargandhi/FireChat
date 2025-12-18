//
//  ChatMessageDM.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 13/10/25.
//

import Foundation
import FirebaseCore

struct ChatMessageModel: Codable {
    
    let id: String?
    let senderId: String?
    let message: String?
    let mediaURL: String?
    var thumbnailURL: String?
    let mediaType: String?
    let timestamp: Date?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case senderId = "senderId"
        case message = "text"
        case mediaURL = "mediaURL"
        case thumbnailURL = "thumbnailURL"
        case mediaType = "mediaType"
        case timestamp = "timestamp"
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        senderId = try values.decodeIfPresent(String.self, forKey: .senderId)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        mediaURL = try values.decodeIfPresent(String.self, forKey: .mediaURL)
        thumbnailURL = try values.decodeIfPresent(String.self, forKey: .thumbnailURL)
        mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType)
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp)
    }
}


struct GroupedMessagesModel {
    
    let date: Date
    var messages: [ChatMessageModel]
}
