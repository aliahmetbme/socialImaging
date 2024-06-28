//
//  CommentModel.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 28.06.2024.
//

import Foundation

class CommentModel {
    var imageUrl:String?
    var useremail:String?
    var comment:String?
    
    init(imageUrl: String? = nil, useremail: String? = nil, comment: String? = nil) {
        self.imageUrl = imageUrl
        self.useremail = useremail
        self.comment = comment
    }
}
