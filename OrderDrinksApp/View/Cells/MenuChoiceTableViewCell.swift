//
//  MenuChoiceTableViewCell.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit

class MenuChoiceTableViewCell: UITableViewCell {
    @IBOutlet weak var menuChoiceItemLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
