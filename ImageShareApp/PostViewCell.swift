//
//  PostViewCell.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 25.06.2024.
//

import UIKit

protocol PostViewCellProtocol {
    func clicked(indexPath: IndexPath)
    func showComments(indexPath:IndexPath)
}

class PostViewCell: UITableViewCell {

    @IBOutlet var userpp: UIImageView!
    @IBOutlet var usernameUpper: UILabel!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var usernameDown: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var cellProtocol:PostViewCellProtocol?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 10
        postImage.clipsToBounds = true
        
        userpp.layer.cornerRadius = 20
        userpp.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likePost(_ sender: Any) {
        cellProtocol?.clicked(indexPath: indexPath!)
    }
    
    @IBAction func showComments(_ sender: Any) {
        cellProtocol?.showComments(indexPath: indexPath!)
    }
    
}
