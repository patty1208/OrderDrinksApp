//
//  OrderNameTableViewCell.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit
protocol OrderNameTableViewCellTapDelegate {
    func isEdit(cell: OrderNameTableViewCell)
}

class OrderNameTableViewCell: UITableViewCell {
    @IBOutlet weak var orderNameTextField: UITextField!
    var delegate: OrderNameTableViewCellTapDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func isEdit(_ sender: UITextField) {
            delegate?.isEdit(cell: self)
    }

}
