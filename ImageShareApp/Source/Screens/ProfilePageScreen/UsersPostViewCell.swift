//
//  UsersPostViewCell.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 29.06.2024.
//

import UIKit

protocol UserPostViewCellProtocol {
    func showComments(indexPath: IndexPath)
}

class UsersPostViewCell: UITableViewCell {
    
    @IBOutlet var userPPImage: UIImageView!
    @IBOutlet var usersPostImage: UIImageView!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var userNameLabe: UILabel!
    
    var cellProtocol: UserPostViewCellProtocol?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usersPostImage.layer.cornerRadius = 10
        usersPostImage.clipsToBounds = true
        
        userPPImage.layer.cornerRadius = 20
        userPPImage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func showComments(_ sender: Any) {
        cellProtocol?.showComments(indexPath: indexPath!)
    }
}
