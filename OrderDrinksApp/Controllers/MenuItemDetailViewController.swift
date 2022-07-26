//
//  MenuItemDetailViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit

protocol MenuDelgate {
    func updateMenuListUIToNonSelected()
}
protocol OrderDelgate {
    func updateOrderListUIToNonSelected()
}

class MenuItemDetailViewController: UIViewController {
    
    
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var orderDetailLabel: UILabel!
    @IBOutlet weak var addQuantityButton: UIButton!
    @IBOutlet weak var reduceQuantityButton: UIButton!
    
    @IBOutlet weak var addCartButton: UIButton!
    
    var menuRecord: MenuResponse.Record
    var orderItem: Order?
    var orderName: String?
    var drinkName: String
    var capacity: Capacity?
    var tempLevel: TempLevel?
    var sugarLevel: SugerLevel?
    var toppings: [Toppings] = []
    var quantity: Int = 1
    var price: Int = 0
    var orderRecord: OrderResponse.Record?
    var delegate: MenuDelgate?
    var orderDelegate: OrderDelgate?
    
    
    init?(coder: NSCoder, menuRecord: MenuResponse.Record){
        self.menuRecord = menuRecord
        self.drinkName = menuRecord.fields.drinkName
        self.capacity = menuRecord.fields.mediumPrice == nil ? .large : menuRecord.fields.largePrice == nil ? .medium : nil
        super.init(coder: coder)
    }
    init?(coder: NSCoder, orderRecord: OrderResponse.Record){
        self.orderRecord = orderRecord
        self.menuRecord = MenuController.shared.menuResponse.records.first(where: {
            $0.fields.drinkName == orderRecord.fields.drinkName
        })!
        self.drinkName = self.menuRecord.fields.drinkName
        self.orderName = orderRecord.fields.orderName
        self.capacity = Capacity(rawValue: orderRecord.fields.capacity)
        self.sugarLevel = SugerLevel(rawValue: orderRecord.fields.sugarLevel)
        self.tempLevel = TempLevel(rawValue: orderRecord.fields.tempLevel)
        if let toppings = orderRecord.fields.toppings?.components(separatedBy: " "){
            self.toppings = toppings.map({ Toppings(rawValue: $0)!})
        } else {
            self.toppings = [Toppings]()
        }
        self.quantity = orderRecord.fields.quantity
        self.price = orderRecord.fields.price
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateButtonUIToAdaptForOtherVersions(){
        if #available(iOS 15, *) {
            addQuantityButton.setImage(UIImage(), for: .normal)
            addQuantityButton.configuration = .plain()
            addQuantityButton.configuration?.background.image = UIImage(named: "plus")
            addQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
            reduceQuantityButton.setImage(UIImage(), for: .normal)
            reduceQuantityButton.configuration = .plain()
            reduceQuantityButton.configuration?.background.image = UIImage(named: "minus")
            reduceQuantityButton.configuration?.background.imageContentMode = .scaleAspectFit
        } else {
            addQuantityButton.setTitle("", for: .normal)
            addQuantityButton.setImage(UIImage(named: "plus"), for: .normal)
            addQuantityButton.imageView?.contentMode = .scaleAspectFit
            
            reduceQuantityButton.setTitle("", for: .normal)
            reduceQuantityButton.setImage(UIImage(named: "minus"), for: .normal)
            reduceQuantityButton.imageView?.contentMode = .scaleAspectFit
            
            addCartButton.layer.cornerRadius = 10
            addCartButton.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    
    func updateUI(){
        addCartButton.setTitle(orderRecord?.id == nil ? " 加入購物車" : " 確定修改訂單", for: .normal)
        reduceQuantityButton.isEnabled = quantity == 1 ? false : true
        reduceQuantityButton.alpha = quantity == 1 ? 0.2 : 1
        
        drinkNameLabel.text = menuRecord.fields.drinkName
        quantityLabel.text = quantity.description
        
        // 訂單客製化選項說明:大杯小杯溫度甜度配料
        var toppingsText = ""
        if toppings == []{
            toppingsText = ""
        } else {
            toppings.forEach { topping in
                toppingsText = toppingsText + topping.rawValue + " "
            }
            toppingsText = "\n"+toppingsText
        }
        orderDetailLabel.text = "\(capacity?.rawValue ?? "")  \(sugarLevel?.rawValue ?? "")  \(tempLevel?.rawValue ?? "")\(toppingsText)"
        
        // 價錢
        if let capacity = capacity {
            price = ((capacity == .large ? menuRecord.fields.largePrice! : menuRecord.fields.mediumPrice!) + toppings.reduce(0, { x, y in
                x + y.price })) * quantity
        }
        
        priceLabel.text = "$ " + price.description
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        delegate?.updateMenuListUIToNonSelected()
        orderDelegate?.updateOrderListUIToNonSelected()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonUIToAdaptForOtherVersions()
        updateUI()
    }
    
    
    @IBAction func addQuantity(_ sender: UIButton) {
        if capacity == nil{
            showAlert(title: "Oops!", message: "請先選擇容量！", exit: false)
        } else {
            quantity += 1
            updateUI()
        }
    }
    @IBAction func reduceQuantity(_ sender: UIButton) {
        quantity -= 1
        updateUI()
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        if orderName == "" || orderName == nil {
            self.showAlert(title: "Oops!", message: "記得填上您的名字唷！", exit: false)
        } else if capacity == nil {
            showAlert(title: "Oops!", message: "記得選擇容量喔", exit: false)
        } else if sugarLevel == nil {
            showAlert(title: "Oops!", message: "甜度？", exit: false)
        } else if tempLevel == nil {
            showAlert(title: "Oops!", message: "記得選擇溫度喔", exit: false)
        } else if quantity == 0 {
            showAlert(title: "Oops!", message: "幾杯？", exit: false)
        } else {
            // 按鈕動畫
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.addCartButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                self.addCartButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            guard let orderName = orderName,
                  let capacity = capacity,
                  let tempLevel = tempLevel,
                  let sugarLevel = sugarLevel else { return }
            
            orderItem = Order(orderName: orderName, drinkName: drinkName, capacity: capacity.rawValue, tempLevel: tempLevel.rawValue, sugarLevel: sugarLevel.rawValue, toppings: toppings.map({$0.rawValue}).joined(separator: " "), quantity: quantity, price: price)
            
            if sender.title(for: .normal) == " 加入購物車"{
                MenuController.shared.postOrder(orderData: orderItem!) { result in
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
                let orderRecord = OrderResponse.Record(id: orderRecord?.id, fields: orderItem!, createdTime: nil)
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
            guard let controller =  MenuItemChoiceTableViewController(coder: coder, menuItem: menuRecord, orderRecord: orderRecord) else { return MenuItemChoiceTableViewController(coder: coder)}
            controller.orderChoiceDelegate = self
            return controller
        } else {
            guard let controller = MenuItemChoiceTableViewController(coder: coder, menuItem: menuRecord) else { return MenuItemChoiceTableViewController(coder: coder)}
            controller.orderChoiceDelegate = self
            return controller
        }
    }
    
}

extension MenuItemDetailViewController: OrderChoiceDelegate {
    func orderName(orderName: String) {
        self.orderName = orderName
    }
    
    func capacityChoice(capacity: Capacity?) {
        self.capacity = capacity
        updateUI()
    }
    
    func sugarLevelChoice(sugarLevel: SugerLevel?) {
        self.sugarLevel = sugarLevel
        updateUI()
    }
    
    func tempLevelChoice(tempLevel: TempLevel?) {
        self.tempLevel = tempLevel
        updateUI()
    }
    
    func toppingsChoice(toppings: [Toppings]) {
        self.toppings = toppings
        updateUI()
    }
    
}
