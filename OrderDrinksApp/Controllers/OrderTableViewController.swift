//
//  OrderTableViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/25.
//

import UIKit

protocol loadOrderDelegate {
    func loadOrder(orderRecords: [OrderResponse.Record])
    func loadAnimating(state: Bool)
}

class OrderTableViewController: UITableViewController {
    
    var orderRecords = [OrderResponse.Record](){
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
            orderRecords = orderRecords.sorted(by: {
                dateFormatter.date(from:$0.createdTime!)!.compare(dateFormatter.date(from:$1.createdTime!)!) == .orderedDescending
            })
        }
    }
    var delegate: loadOrderDelegate?
    
    // MARK: - UI
    @objc func updateOrderRecordsUI(notification: Notification) {
        MenuController.shared.fetchOrderRecords { (result) in
            switch result {
            case .success(let orderRecords):
                self.updateUI(with: orderRecords)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
            }
        }
    }
    
    func showAlert(title: String, message: String, exit: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if exit == true {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUI(with orderRecords: [OrderResponse.Record]) {
        DispatchQueue.main.async {
            self.orderRecords = orderRecords
            self.tableView.reloadData()
            self.delegate?.loadOrder(orderRecords: self.orderRecords)
            self.delegate?.loadAnimating(state: false)
        }
        
    }
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.loadAnimating(state: true)
        MenuController.shared.fetchOrderRecords { (result) in
            switch result {
            case .success(let orderRecords):
                self.updateUI(with: orderRecords)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
            }
        }
        // 當新增修改訂單後，訂單頁面可以即時重新載入訂單資料
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderRecordsUI), name: Notification.Name(rawValue: "UpdateOrderRecordsUI"), object: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderRecords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderTableViewCell.self)", for: indexPath) as? OrderTableViewCell else { return UITableViewCell()}
        let order = orderRecords[indexPath.row].fields
        let toppingsDescription = order.toppings ?? ""
        cell.OrderNameLabel.text = order.orderName
        cell.DrinkNameLabel.text = order.drinkName
        cell.OrderDetailLabel.text = "\(order.capacity) \(order.tempLevel) \(order.sugarLevel)\(toppingsDescription != "" ? "\n" + toppingsDescription : "")"
        cell.quantityLabel.text = order.quantity.description + " 杯"
        cell.priceLabel.text = "$ " +  order.price.description
        return cell
    }
    
    // MARK: - Table view delegate
    // 滑動取消或選擇按鈕後
//    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        delegate?.loadOrder(orderRecords: orderRecords)
//    }
    
    // 左滑
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let orderRecord = orderRecords[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { (action, view, completionHandler) in
            // 按鈕要做的事
            // 刪除資料
            let alertController = UIAlertController(title: "\(orderRecord.fields.orderName)  的   \(orderRecord.fields.drinkName)", message: "確定刪除此筆訂單嗎？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                self.delegate?.loadAnimating(state: true)
                MenuController.shared.deleteOrder(orderID: self.orderRecords[indexPath.row].id!) { result in
                    switch result {
                    case .success(_):
                        self.orderRecords.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            self.delegate?.loadOrder(orderRecords: self.orderRecords)
                            self.delegate?.loadAnimating(state: false)
                        }
                    case .failure(let error ):
                        print("DeleteOrder failed:\(error)")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            // 刪除儲存格
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(red: 82/255, green: 24/255, blue: 38/255, alpha: 0.5)
        
        // 左滑選項
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
     // MARK: - Navigation
    @IBSegueAction func passOrderRecord(_ coder: NSCoder) -> MenuItemDetailViewController? {
        guard let selectedRow = tableView.indexPathForSelectedRow?.row else { return MenuItemDetailViewController(coder: coder) }
        let orderRecord = orderRecords[selectedRow]
        let controller = MenuItemDetailViewController(coder: coder, orderRecord: orderRecord)
        return controller
    }
}
