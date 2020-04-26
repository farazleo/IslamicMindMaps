//
//  TableViewCell.swift
//  IslamicMindMaps
//
//  Created by Faraz Ahmed on 19/04/2020.
//  Copyright © 2020 Faraz Ahmed. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var romanName: UILabel!
    
    @IBOutlet weak var arabicName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
