//
//  PostModel.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 25.06.2024.
//

import Foundation

class PostModel {
    
    var email: String?
    var imageUrl: String?
    var description: String?
    var date: String?
    var comments: [String]
    var likeCount: Int
    var usersProfileImageUrl: String
    var postId: String
    
    init(email: String? = nil, imageUrl: String? = nil, description: String? = nil, date: String? = nil, comments: [String], likeCount: Int, usersProfileImageUrl: String, postId: String) {
        self.email = email
        self.imageUrl = imageUrl
        self.description = description
        self.date = date
        self.comments = comments
        self.likeCount = likeCount
        self.usersProfileImageUrl = usersProfileImageUrl
        self.postId = postId
    }
}
