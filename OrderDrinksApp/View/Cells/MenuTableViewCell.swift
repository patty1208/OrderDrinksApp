//
//  MenuTableViewCell.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/22.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var aboutDrinkLabel: UILabel!
    @IBOutlet weak var recommendImageView: UIImageView!{
        didSet {
            recommendImageView.tintColor = UIColor(red: 247/255, green: 205/255, blue: 70/255, alpha: 1)
        }
    }
    @IBOutlet weak var onlyColdOrHot: UIImageView!
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
