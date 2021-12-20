//
//  OrderTableViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/25.
//

import UIKit

protocol loadOrderDelegate {
    func loadOrder(orderRecords: [OrderRecord])
    func loadAnimatiing(state: Bool)
}

class OrderTableViewController: UITableViewController {
    
    var orderRecords = [OrderRecord](){
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
            orderRecords = orderRecords.sorted(by: {
                dateFormatter.date(from:$0.createdTime!)!.compare(dateFormatter.date(from:$1.createdTime!)!) == .orderedDescending

            })
        }
    }
    var delegate: loadOrderDelegate?
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MenuController.shared.fetchOrderRecords { (result) in
            switch result {
            case .success(let orderRecords):
                self.updateUI(with: orderRecords)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
            }
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderRecordsUI), name: Notification.Name(rawValue: "UpdateOrderRecordsUI"), object: nil)
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUI(with orderRecords: [OrderRecord]) {
        DispatchQueue.main.async {
            self.orderRecords = orderRecords
            self.tableView.reloadData()
            self.delegate?.loadOrder(orderRecords: self.orderRecords)
        }
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderRecords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderTableViewCell.self)", for: indexPath) as? OrderTableViewCell else { return UITableViewCell()}
        let orderRecord = orderRecords[indexPath.row].fields
        let toppingsDescription = orderRecord.toppings ?? ""
        cell.OrderNameLabel.text = orderRecord.orderName
        cell.DrinkNameLabel.text = orderRecord.drinkName
        cell.OrderDetailLabel.text = "\(orderRecord.capacity) \(orderRecord.tempLevel) \(orderRecord.sugarLevel)\(toppingsDescription != "" ? "\n" + toppingsDescription : "")"
        cell.quantityLabel.text = orderRecord.quantity.description + " 杯"
        cell.priceLabel.text = "$ " +  orderRecord.price.description
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 84/255, green: 24/255, blue: 38/255, alpha: 0.2)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // 滑動取消或選擇按鈕後
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        delegate?.loadOrder(orderRecords: orderRecords)
    }
    
    // 左滑
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 樣式: .normal 預設灰色, .destructive 紅色
        //        let go = UIContextualAction(style: .normal, title: "更多") { (action, view, completionHandler) in
        //            // 按鈕要做的事
        //            print(tableView.isEditing)
        //            completionHandler(true)
        //        }
        //        go.backgroundColor = .blue
        
        // -------
        let orderRecord = orderRecords[indexPath.row]
        let del = UIContextualAction(style: .destructive, title: "刪除") { (action, view, completionHandler) in
            // 按鈕要做的事
            // 刪除資料
            let alertController = UIAlertController(title: "\(orderRecord.fields.orderName)  的   \(orderRecord.fields.drinkName)", message: "確定刪除此筆訂單嗎？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                self.delegate?.loadAnimatiing(state: true)
                MenuController.shared.deleteOrder(orderID: self.orderRecords[indexPath.row].id!) { result in
                    switch result {
                    case .success(_):
                        self.orderRecords.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            self.delegate?.loadOrder(orderRecords: self.orderRecords)
                            self.delegate?.loadAnimatiing(state: false)
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
        
        del.backgroundColor = UIColor(red: 82/255, green: 24/255, blue: 38/255, alpha: 0.5)
        
        // 左滑選項
        let config = UISwipeActionsConfiguration(actions: [del])
        config.performsFirstActionWithFullSwipe = false
        return config
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBSegueAction func passOrderRecord(_ coder: NSCoder) -> MenuItemDetailViewController? {
        
        guard let selectedRow = tableView.indexPathForSelectedRow?.row else { return MenuItemDetailViewController(coder: coder) }
        let orderRecord = orderRecords[selectedRow]
        let controller = MenuItemDetailViewController(coder: coder, orderRecord: orderRecord)
        controller?.orderDelegate = self
        return controller
    }
}

extension OrderTableViewController: OrderDelgate {
    func updateOrderListUIToNonSelected() {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: false)
    }
}
