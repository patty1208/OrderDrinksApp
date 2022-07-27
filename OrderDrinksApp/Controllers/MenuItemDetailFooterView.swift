//
//  MenuItemDetailFooterView.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2022/7/27.
//

import UIKit

class MenuItemDetailFooterView: UIView {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var orderDetailLabel: UILabel!
    @IBOutlet weak var addQuantityButton: UIButton! {
        didSet {
            if #available(iOS 15, *) {
                addQuantityButton.setImage(UIImage(), for: .normal)
                addQuantityButton.configuration = .plain()
                addQuantityButton.configuration?.background.image = UIImage(named: "plus")
                addQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
            } else {
                addQuantityButton.setTitle("", for: .normal)
                addQuantityButton.setImage(UIImage(named: "plus"), for: .normal)
                addQuantityButton.imageView?.contentMode = .scaleAspectFit
            }
        }
    }
    @IBOutlet weak var reduceQuantityButton: UIButton! {
        didSet {
            if #available(iOS 15, *) {
                reduceQuantityButton.setImage(UIImage(), for: .normal)
                reduceQuantityButton.configuration = .plain()
                reduceQuantityButton.configuration?.background.image = UIImage(named: "minus")
                reduceQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
            } else {
                reduceQuantityButton.setTitle("", for: .normal)
                reduceQuantityButton.setImage(UIImage(named: "minus"), for: .normal)
                reduceQuantityButton.imageView?.contentMode = .scaleAspectFit
            }
        }
    }
    @IBOutlet weak var addCartButton: UIButton! {
        didSet {
            addCartButton.layer.cornerRadius = 10
            addCartButton.layer.backgroundColor = UIColor.white.cgColor
        }
    }
}
