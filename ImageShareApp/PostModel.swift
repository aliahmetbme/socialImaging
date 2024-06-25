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
    
    init(email: String? = nil, imageUrl: String? = nil, description: String? = nil, date: String? = nil) {
        self.email = email
        self.imageUrl = imageUrl
        self.description = description
        self.date = date
    }
}
