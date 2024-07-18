//
//  Extension+String.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import Foundation
import UIKit

extension UIImageView {
    
    func initialPictureDesign(cornerRadius: CGFloat = 50) {
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    func profileSettingsPagePictureDesign(cornerRadius: CGFloat = 50) {
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2
        self.layer.shadowOffset = CGSize(width: 5, height: 4)
    }

    func setInitialImages() {
        if traitCollection.userInterfaceStyle == .dark {
            self.image = UIImage(named: "ppImageDark")
        } else {
            self.image = UIImage(named: "ppImage")
        }
    }
}
