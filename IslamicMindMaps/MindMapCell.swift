//
//  MindMapCell.swift
//  MindMaps
//
//  Created by Muhammad Ibrahim on 17/04/2020.
//  Copyright © 2020 ARCeus. All rights reserved.
//

import UIKit
import SDWebImage
class MindMapCell: UITableViewCell {
    
    @IBOutlet weak var mindMapImageView: UIImageView!
    
    @IBOutlet weak var verseNo: UILabel!
    
    var mindMap: MindMap? {
        didSet{
            //mindMapImageView.sd_setImage(with: mindMap!.mindMapUrl, completed: nil)
            mindMapImageView.sd_setImage(with: mindMap!.mindMapUrl, placeholderImage: UIImage(named: "loading"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
