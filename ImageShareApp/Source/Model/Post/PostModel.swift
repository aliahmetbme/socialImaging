//
//  PostModel.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 25.06.2024.
//

import Foundation

struct PostModel {
    
    let  postImageUrl: String?
    let  userUID: String?
    let  description: String?
    let  date: String?
    let  comments: [String]
    var  likeCount: Int
    let  postId: String

}

struct PostUploadModel {
    let  imageUrl: String?
    let  userUID: String?
    let  comment: String?
    let  date: Any?
    let  comments: [String]?
    var  likeCount: Int?
    var  likes: [String]?
    
    
    func toDictionary() -> [String: Any] {
        return [
            "imageUrl": imageUrl!,
            "userUID": userUID!,
            "comment": comment!,
            "date": date!,
            "comments": comments!,
            "likeCount": likeCount!,
            "likes": likes!
        ]
    }
}


