import UIKit


class UsersPostViewCell: UITableViewCell {

    @IBOutlet var postImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 10
        postImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
