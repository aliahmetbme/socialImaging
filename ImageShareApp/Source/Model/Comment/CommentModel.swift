//
//  CommentModel.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 28.06.2024.
//

import Foundation

struct CommentModel {
    let userUID: String?
    let userName: String?
    let comment: String?
}

struct UploadCommentModel {
    let userUID: String?
    let username: String?
    let comment: String?
    let timestamp: Any?
    
    func toDictionary() -> [String: Any] {
        return [
            "userUID": userUID!,
            "username": username!,
            "comment": comment!,
            "timestamp": timestamp!
        ]
    }
}
