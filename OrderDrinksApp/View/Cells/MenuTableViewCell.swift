//
//  MenuTableViewCell.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/22.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var aboutDrinkLabel: UILabel!
    @IBOutlet weak var recommendImageView: UIImageView!
    @IBOutlet weak var onlyColdOrHot: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
