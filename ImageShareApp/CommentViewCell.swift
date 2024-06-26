//
//  CommentViewCell.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 26.06.2024.
//

import UIKit

class CommentViewCell: UITableViewCell {

    @IBOutlet var ppImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var commentLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ppImage.layer.cornerRadius = 20
        ppImage.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
