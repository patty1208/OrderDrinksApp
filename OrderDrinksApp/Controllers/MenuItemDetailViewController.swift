//
//  MenuItemDetailViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit

class MenuItemDetailViewController: UIViewController {
    
    
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var footerView: MenuItemDetailFooterView!
    
    var menuRecord: MenuResponse.Record
    var orderRecord: OrderResponse.Record?
    var orderItem = OrderItem(orderName: "", drinkName: "", toppings: [], quantity: 1, price: 0)
    
    init?(coder: NSCoder, menuRecord: MenuResponse.Record){
        self.menuRecord = menuRecord
        super.init(coder: coder)
    }
    init?(coder: NSCoder, orderRecord: OrderResponse.Record){
        self.orderRecord = orderRecord
        self.menuRecord = MenuController.shared.menuResponse.records.first(where: {
            $0.fields.drinkName == orderRecord.fields.drinkName
        })!
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
//    func updateButtonUIToAdaptForOtherVersions(){
//        if #available(iOS 15, *) {
//            addQuantityButton.setImage(UIImage(), for: .normal)
//            addQuantityButton.configuration = .plain()
//            addQuantityButton.configuration?.background.image = UIImage(named: "plus")
//            addQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
//            reduceQuantityButton.setImage(UIImage(), for: .normal)
//            reduceQuantityButton.configuration = .plain()
//            reduceQuantityButton.configuration?.background.image = UIImage(named: "minus")
//            reduceQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
//        } else {
//            addQuantityButton.setTitle("", for: .normal)
//            addQuantityButton.setImage(UIImage(named: "plus"), for: .normal)
//            addQuantityButton.imageView?.contentMode = .scaleAspectFit
//
//            reduceQuantityButton.setTitle("", for: .normal)
//            reduceQuantityButton.setImage(UIImage(named: "minus"), for: .normal)
//            reduceQuantityButton.imageView?.contentMode = .scaleAspectFit
//
//            addCartButton.layer.cornerRadius = 10
//            addCartButton.layer.backgroundColor = UIColor.white.cgColor
//        }
//    }
    
    func updateUI(){
        // 初始畫面
        footerView.addCartButton.setTitle(orderRecord?.id == nil ? " 加入購物車" : " 確定修改訂單", for: .normal)
        drinkNameLabel.text = menuRecord.fields.drinkName
        
        // 隨數量變動
        footerView.reduceQuantityButton.isEnabled = orderItem.quantity == 1 ? false : true
        footerView.reduceQuantityButton.alpha = orderItem.quantity == 1 ? 0.2 : 1
        footerView.quantityLabel.text = orderItem.quantity.description
        
        // 訂單客製化選項說明:大杯小杯溫度甜度配料
        // 隨訂單選項點選變動
        var toppingsText = ""
    
        if orderItem.toppings == [] {
            toppingsText = ""
        } else {
            orderItem.toppings.forEach { topping in
                toppingsText = toppingsText + topping.rawValue + " "
            }
            toppingsText = "\n" + toppingsText
        }
        footerView.orderDetailLabel.text = "\(orderItem.capacity?.rawValue ?? "")  \(orderItem.sugarLevel?.rawValue ?? "")  \(orderItem.tempLevel?.rawValue ?? "")\(toppingsText)"
        
        // 價錢
        if let capacity = orderItem.capacity {
            orderItem.price = ((capacity == .large ? menuRecord.fields.largePrice! : menuRecord.fields.mediumPrice!) + orderItem.toppings.reduce(0, { x, y in
                x + y.price })) * orderItem.quantity
        }
        footerView.priceLabel.text = "$ " + orderItem.price.description
        
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
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    
    @IBAction func addQuantity(_ sender: UIButton) {
        if orderItem.capacity == nil {
            showAlert(title: "Oops!", message: "請先選擇容量！", exit: false)
        } else {
            orderItem.quantity += 1
            updateUI()
        }
    }
    @IBAction func reduceQuantity(_ sender: UIButton) {
        orderItem.quantity -= 1
        updateUI()
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        if orderItem.orderName == "" {
            self.showAlert(title: "Oops!", message: "記得填上您的名字唷！", exit: false)
        } else if orderItem.capacity == nil {
            showAlert(title: "Oops!", message: "記得選擇容量喔", exit: false)
        } else if orderItem.sugarLevel == nil {
            showAlert(title: "Oops!", message: "甜度？", exit: false)
        } else if orderItem.tempLevel == nil {
            showAlert(title: "Oops!", message: "記得選擇溫度喔", exit: false)
        } else if orderItem.quantity == 0 {
            showAlert(title: "Oops!", message: "幾杯？", exit: false)
        } else {
            // 按鈕動畫
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.footerView.addCartButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                self.footerView.addCartButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            guard let capacity = orderItem.capacity,
                  let tempLevel = orderItem.tempLevel,
                  let sugarLevel = orderItem.sugarLevel else { return }
            let order = Order(orderName: orderItem.orderName, drinkName: orderItem.drinkName, capacity: capacity.rawValue, tempLevel: tempLevel.rawValue, sugarLevel: sugarLevel.rawValue, toppings: orderItem.toppings.map({$0.rawValue}).joined(separator: " "), quantity: orderItem.quantity, price: orderItem.price)

            if sender.title(for: .normal) == " 加入購物車"{
                MenuController.shared.postOrder(orderData: order) { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            self.showAlert(title: "Thank You!", message: "訂購成功！",exit: true)
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateOrderRecordsUI"), object: self, userInfo: nil)
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.showAlert(title: "Oops!", message: "上傳訂單失敗！",exit: true)
                        }
                    }
                }
            } else {
                let orderRecord = OrderResponse.Record(id: orderRecord?.id, fields: order, createdTime: nil)
                let orderResponse = OrderResponse.init(records: [orderRecord])
                MenuController.shared.updateOrder(orderData: orderResponse) { result in
                    switch result{
                    case .success(let content):
                        guard let id = self.orderRecord?.id else { return }
                        if content.contains("\(id)") {
                            print("I found the record of id \(id)")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Thank You!", message: "修改成功！",exit: true)
                            }
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateOrderRecordsUI"), object: self, userInfo: nil)
                        } else {
                            print("I can't find the record of id \(id)")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Oops!", message: "修改訂單失敗！",exit: true)
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.showAlert(title: "Oops!", message: "修改訂單失敗！",exit: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    @IBSegueAction func passMenuItem(_ coder: NSCoder) -> MenuItemChoiceTableViewController? {
        if let orderRecord = orderRecord{
            guard let controller =  MenuItemChoiceTableViewController(coder: coder, menuRecord: menuRecord, orderRecord: orderRecord) else { return MenuItemChoiceTableViewController(coder: coder)}
            controller.orderChoiceDelegate = self
            return controller
        } else {
            guard let controller = MenuItemChoiceTableViewController(coder: coder, menuRecord: menuRecord) else { return MenuItemChoiceTableViewController(coder: coder)}
            controller.orderChoiceDelegate = self
            return controller
        }
    }
    
}

extension MenuItemDetailViewController: OrderChoiceDelegate {
    func passOrderItem(orderItem: OrderItem) {
        self.orderItem = orderItem
        updateUI()
    }
}
