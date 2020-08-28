//
//  TableViewCell.swift
//  MLVisionExample
//
//  Created by Austin Rath on 2/16/20.
//  Copyright © 2020 Google Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
