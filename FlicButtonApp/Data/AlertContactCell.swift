//
//  AlertContactCell.swift
//  FlicButtonApp
//
//  Created by Macbook on 11/8/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit

class AlertContactCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
