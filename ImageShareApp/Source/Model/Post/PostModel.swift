//
//  PostModel.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 25.06.2024.
//

import Foundation

struct PostModel {
    
    let  email: String?
    let  imageUrl: String?
    let  description: String?
    let  date: String?
    let  comments: [String]
    var  likeCount: Int
    let  usersProfileImageUrl: String
    let  postId: String

}
