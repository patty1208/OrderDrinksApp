//
//  MenuItemChoiceTableViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit

protocol OrderChoiceDelegate {
    func passOrderItem(orderItem: OrderItem) // 傳遞資料:tableview選擇後傳遞
}

class MenuItemChoiceTableViewController: UITableViewController {
    var orderChoiceDelegate: OrderChoiceDelegate?

    let menuRecord: MenuResponse.Record
    var orderRecord: OrderResponse.Record?
    var orderItem = OrderItem(orderName: "", drinkName: "", toppings: [], quantity: 1, price: 0)

    let categories = OrderCategory.allCases
    var choices: [String:[Any]] = [String:[Any]]()
    var capacityChoice: [Capacity] = []
    var tempChoice: [TempLevel] = []
    
    init?(coder: NSCoder, menuRecord: MenuResponse.Record){
        self.menuRecord = menuRecord
        self.capacityChoice = menuRecord.fields.largePrice == nil ? [.medium] : menuRecord.fields.mediumPrice == nil ? [.large] : [.large, .medium]
        self.tempChoice = menuRecord.fields.onlyHot == nil ? (menuRecord.fields.onlyCold == nil ? TempLevel.allCases : [.normal, .less, .light, .no]) :  [.hot]
        self.choices = ["訂購人":[""],
                   "容量":self.capacityChoice,
                   "甜度":SugerLevel.allCases,
                   "溫度":self.tempChoice,
                   "配料":Toppings.allCases]
        self.orderItem.drinkName = menuRecord.fields.drinkName
        self.orderItem.capacity = menuRecord.fields.mediumPrice == nil ? .large : menuRecord.fields.largePrice == nil ? .medium : nil
        self.orderItem.tempLevel = menuRecord.fields.onlyHot == nil ? nil : .hot
        super.init(coder: coder)
    }

    init?(coder: NSCoder, menuRecord: MenuResponse.Record, orderRecord: OrderResponse.Record){
        self.menuRecord = menuRecord
        self.capacityChoice = menuRecord.fields.largePrice == nil ? [.medium] : menuRecord.fields.mediumPrice == nil ? [.large] : [.large, .medium]
        self.tempChoice = menuRecord.fields.onlyHot == nil ? (menuRecord.fields.onlyCold == nil ? TempLevel.allCases : [.normal, .less, .light, .no]) :  [.hot]
        self.choices = ["訂購人":[""],
                   "容量":self.capacityChoice,
                   "甜度":SugerLevel.allCases,
                   "溫度":self.tempChoice,
                   "配料":Toppings.allCases]
        self.orderRecord = orderRecord
        self.orderItem = OrderItem(orderName: orderRecord.fields.orderName, drinkName: orderRecord.fields.drinkName, capacity: Capacity(rawValue: orderRecord.fields.capacity), tempLevel: TempLevel(rawValue: orderRecord.fields.tempLevel), sugarLevel: SugerLevel(rawValue: orderRecord.fields.sugarLevel), toppings: [Toppings](), quantity: orderRecord.fields.quantity, price: orderRecord.fields.price)
        if let toppings = orderRecord.fields.toppings?.components(separatedBy: " "){
            self.orderItem.toppings = toppings.map({ Toppings(rawValue: $0)!})
        } else {
            self.orderItem.toppings = [Toppings]()
        }
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 點擊空白處收起 textfield 的 input view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        tableView.allowsMultipleSelection = true
        
        orderChoiceDelegate?.passOrderItem(orderItem: orderItem)
    }
    
    // MARK: - 其他
    @IBAction func dismissKeyboard(_ sender: UITextField) {
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return choices.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        guard let choiceByCategory = choices[category.rawValue] else { return 0 }
        return choiceByCategory.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[indexPath.section]
        switch category {
        case .orderName:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderNameTableViewCell.self)", for: indexPath) as? OrderNameTableViewCell else { return UITableViewCell() }
            cell.orderNameTextField.text = orderItem.orderName
            cell.delegate = self
            cell.orderNameTextField.becomeFirstResponder()
            return cell
        case .capacity:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [Capacity]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = orderItem.capacity?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")

            }
            return cell
        case .sugerLevel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [SugerLevel]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = orderItem.sugarLevel?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        case .tempLevel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [TempLevel]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = orderItem.tempLevel?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        case .toppings:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [Toppings]{
                cell.menuChoiceItemLabel.text = " \(choiceDetail[indexPath.row].rawValue)  +$\(choiceDetail[indexPath.row].price)"
                cell.checkImageView.image = orderItem.toppings.contains(choiceDetail[indexPath.row]) == true ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        categories[section].rawValue
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.section]
        switch category {
        case .orderName: break
        case .capacity:
            orderItem.capacity = capacityChoice[indexPath.row]
        case .sugerLevel:
            orderItem.sugarLevel = SugerLevel.allCases[indexPath.row]
        case .tempLevel:
            orderItem.tempLevel = tempChoice[indexPath.row]
        case .toppings:
            if orderItem.toppings.contains(Toppings.allCases[indexPath.row]) == false {
                orderItem.toppings.append(Toppings.allCases[indexPath.row])
            } else {
                orderItem.toppings.remove(at: orderItem.toppings.firstIndex(of: Toppings.allCases[indexPath.row])!)
            }
        }
        orderChoiceDelegate?.passOrderItem(orderItem: orderItem)
        tableView.reloadData()
    }
}

extension MenuItemChoiceTableViewController: OrderNameTableViewCellTapDelegate {
    func isEdit(cell: OrderNameTableViewCell) {
        guard let orderName = cell.orderNameTextField.text else { return }
        self.orderItem.orderName = orderName
        orderChoiceDelegate?.passOrderItem(orderItem: self.orderItem)
    }
}
