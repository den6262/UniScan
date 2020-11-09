

import UIKit

class DocumentCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var documentType: UILabel!
}

class ProductCell: UITableViewCell {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var subtitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class ProductCellView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowRadius = 5.5
        layer.shadowOpacity = 1.1
        layer.shadowOffset = CGSize.zero
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.5
        layer.masksToBounds = false
        
    }
    
}
