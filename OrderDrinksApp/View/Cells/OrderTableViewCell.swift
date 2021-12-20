//
//  OrderTableViewCell.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/25.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var OrderNameLabel: UILabel!
    @IBOutlet weak var DrinkNameLabel: UILabel!
    @IBOutlet weak var OrderDetailLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
