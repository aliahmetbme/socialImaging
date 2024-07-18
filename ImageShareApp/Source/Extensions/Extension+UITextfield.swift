//
//  Extension+UITextfield.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 15.07.2024.
//

import Foundation
import UIKit

extension UITextField {
    
    func showErrorMessage(messageLabel: UILabel, message: String) {
        
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        messageLabel.isHidden = false
        messageLabel.text = message
    }
    
    func initialTextFieldDesign(borderWidth: CGFloat = 1.0, cornerRadius: CGFloat = 20.0, paddingWidth: CGFloat = 15) {
        
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        
        if traitCollection.userInterfaceStyle == .dark {
            self.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            self.layer.borderColor = UIColor.gray.cgColor
        }
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
