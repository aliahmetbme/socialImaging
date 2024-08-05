//
//  DBEndPoints.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.07.2024.
//

import Foundation

enum DBEndPoints {
    case Post
    case User
    case media
    case uuidjpg(uuid: UUID)
    case username
    case userName
    case userUID
    case date
    case imageUrl
    case comment
    case comments
    case likeCount
    case likes
    
    var endPointsString: String {
        switch self {
        case .Post:
            return "Post"
        case .User:
            return "User"
        case .media:
            return "media"
        case .uuidjpg(let uuid):
            return "\(uuid).jpg"
        case .username:
            return "username"
        case .userName:
            return "userName"
        case .userUID:
            return "userUID"
        case .date:
            return "date"
        case .imageUrl:
            return "imageUrl"
        case .comment:
            return "comment"
        case .comments:
            return "comments"
        case .likeCount:
            return "likeCount"
        case .likes:
            return "likes"
        }
    }
}
