//
//  UsersPostViewCell.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 29.06.2024.
//

import UIKit
import SnapKit

protocol UserPostViewCellProtocol {
    func showComments(indexPath: IndexPath)
    func clicked(indexPath: IndexPath)
}

class UsersPostViewCell: UITableViewCell {
    
    @IBOutlet var userPPImage: UIImageView!
    @IBOutlet var usersPostImage: UIImageView!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var userNameUpperLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var userNameLabe: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    var cellProtocol: UserPostViewCellProtocol?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usersPostImage.layer.cornerRadius = 10
        usersPostImage.clipsToBounds = true
        
        usersPostImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(usersPostImage.snp.width)
        }
        
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
    
    @IBAction func clicked(_ sender: Any) {
        cellProtocol?.clicked(indexPath: indexPath!)
    }
    
}
