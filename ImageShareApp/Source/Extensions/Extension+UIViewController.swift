//
//  Extension+UIViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import Foundation
import UIKit

extension UIViewController {
    func passwordMatchCheck(password: UITextField, rePassword: UITextField) -> Bool {
        if (password.text == "" || rePassword.text == "") {return false}
        return (password.text == rePassword.text)
    }
}
