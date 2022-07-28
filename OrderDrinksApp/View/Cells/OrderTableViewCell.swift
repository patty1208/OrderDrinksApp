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
        // 點選cell的背景顏色
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 84/255, green: 24/255, blue: 38/255, alpha: 0.2)
        self.selectedBackgroundView = backgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
