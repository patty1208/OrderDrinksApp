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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    func updateUI(with orderRecords: [OrderResponse.Record]) {
        self.totalPriceLabel.text = " $ \(orderRecords.reduce(0, {$0+$1.fields.price}).description)"
        self.totalQuantityLabel.text = "共 \(orderRecords.reduce(0, {$0+$1.fields.quantity})) 杯"
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBSegueAction func passOrderRecords(_ coder: NSCoder) -> OrderTableViewController? {
        let controller = OrderTableViewController(coder: coder)
        controller?.delegate = self
        return controller
    }
    
}

extension OrderViewController: loadOrderDelegate {
    func loadAnimatiing(state: Bool) {
        if state == true{
            loading.startAnimating()
        } else {
            loading.stopAnimating()
        }
    }
    
    func loadOrder(orderRecords: [OrderResponse.Record]) {
        self.orderRecords = orderRecords
        updateUI(with: orderRecords)
    }
    
}
