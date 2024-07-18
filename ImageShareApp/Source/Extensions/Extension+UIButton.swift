//
//  Extension+UIButton.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 15.07.2024.
//

import Foundation
import UIKit

extension UIButton {
    
    func initialButtonDesign(cornerRadius: CGFloat = 25, imagePadding: CGFloat = 10) {
        self.layer.cornerRadius = cornerRadius
        if #available(iOS 15.0, *) {
            self.configuration?.imagePadding = imagePadding
        } else {
            // Fallback on earlier versions
        }
        self.clipsToBounds = true
    }
}
