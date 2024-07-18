//
//  Enums.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 18.07.2024.
//

import Foundation

enum AuthError: String {
    case emailAlreadyInUse = "The email address is already in use by another account."
    case internalError = "An internal error has occurred."
    case invalidEmail = "The email address is badly formatted."
    case invalidCredential = "The supplied auth credential is malformed or has expired"
    case invalidPassword = "The password must be 6 characters long or more"
}

