//
//  OrderViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/25.
//

import UIKit

class OrderViewController: UIViewController {
    
    var orderRecords = [OrderResponse.Record]()
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalQuantityLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - UI
    func updateUI(with orderRecords: [OrderResponse.Record]) {
        self.totalPriceLabel.text = " $ \(orderRecords.reduce(0, {$0+$1.fields.price}).description)"
        self.totalQuantityLabel.text = "共 \(orderRecords.reduce(0, {$0+$1.fields.quantity})) 杯"
    }
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()        
    }

    // MARK: - Navigation
    @IBSegueAction func passOrderRecords(_ coder: NSCoder) -> OrderTableViewController? {
        let controller = OrderTableViewController(coder: coder)
        controller?.delegate = self
        return controller
    }
}

extension OrderViewController: LoadOrderDelegate {
    func loadAnimating(state: Bool) {
        if state == true{
            loadingActivityIndicatorView.startAnimating()
        } else {
            loadingActivityIndicatorView.stopAnimating()
        }
    }
    
    func loadOrder(orderRecords: [OrderResponse.Record]) {
        self.orderRecords = orderRecords
        updateUI(with: orderRecords)
    }
    
}
