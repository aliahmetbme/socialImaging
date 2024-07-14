//
//  Extension+String.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import Foundation
import UIKit

extension UITextField {
    
    func initialTextFieldDesign(borderWidth: CGFloat = 1.0, cornerRadius: CGFloat = 8.0, paddingWidth: CGFloat = 10) {
        
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        
        if traitCollection.userInterfaceStyle == .dark {
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderColor = UIColor.black.cgColor
        }
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
