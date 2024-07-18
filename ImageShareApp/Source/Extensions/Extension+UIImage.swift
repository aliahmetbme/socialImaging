//
//  Extension+UIImage.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 17.07.2024.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

