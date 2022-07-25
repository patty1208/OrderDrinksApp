//
//  MenuItemChoiceTableViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/24.
//

import UIKit

protocol OrderChoiceDelegate {
    // 傳遞資料:tableview選擇後傳遞
    func orderName(orderName: String)
    func capacityChoice(capacity: Capacity?)
    func sugarLevelChoice(sugarLevel: SugerLevel?)
    func tempLevelChoice(tempLevel: TempLevel?)
    func toppingsChoice(toppings: [Toppings])
}

class MenuItemChoiceTableViewController: UITableViewController {
    
    var capacityChoice: [Capacity] = []
    var tempChoice: [TempLevel] = []
    var choices: [String:[Any]] = [String:[Any]]()
    let categories = OrderCategory.allCases
    let menuItem: MenuResponse.Record
    var orderName: String = ""
    var capacity: Capacity?
    var tempLevel: TempLevel?
    var sugarLevel: SugerLevel?
    var toppings: [Toppings] = []
    var orderRecord: OrderResponse.Record?
    
    var orderChoiceDelegate: OrderChoiceDelegate?
    
    init?(coder: NSCoder, menuItem: MenuResponse.Record){
        self.menuItem = menuItem
        self.capacity = menuItem.fields.mediumPrice == nil ? .large : menuItem.fields.largePrice == nil ? .medium : nil
        super.init(coder: coder)
    }
    
    init?(coder: NSCoder, menuItem: MenuResponse.Record, orderRecord: OrderResponse.Record){
        self.menuItem = menuItem
        self.orderRecord = orderRecord
        self.orderName = orderRecord.fields.orderName
        self.capacity = Capacity(rawValue: orderRecord.fields.capacity)
        self.sugarLevel = SugerLevel(rawValue: orderRecord.fields.sugarLevel)
        self.tempLevel = TempLevel(rawValue: orderRecord.fields.tempLevel)
        if let toppings = orderRecord.fields.toppings?.components(separatedBy: " "){
            self.toppings = toppings.map({ Toppings(rawValue: $0)!})
        } else {
            self.toppings = [Toppings]()
        }
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 點擊空白處收起 textfield 的 input view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        tableView.allowsMultipleSelection = true
        
        capacityChoice = menuItem.fields.largePrice == nil ? [.medium] : menuItem.fields.mediumPrice == nil ? [.large] : [.large, .medium]
        tempChoice = menuItem.fields.onlyHot == nil ? menuItem.fields.onlyCold == nil ? TempLevel.allCases : [.normal, .less, .light, .no] : [.hot]
        choices = ["訂購人":[""],
                   "容量":self.capacityChoice,
                   "甜度":SugerLevel.allCases,
                   "溫度":self.tempChoice,
                   "配料":Toppings.allCases]
    }
    
    @IBAction func editOrderName(_ sender: UITextField) {
        guard let orderName = sender.text else { return }
        self.orderName = orderName
        orderChoiceDelegate?.orderName(orderName: orderName)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITextField) {
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
            cell.orderNameTextField.text = orderName
            if self.orderRecord == nil {
                cell.orderNameTextField.becomeFirstResponder()
            }
            return cell
        case .capacity:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [Capacity]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = capacity?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        case .sugerLevel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [SugerLevel]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = sugarLevel?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        case .tempLevel:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [TempLevel]{
                cell.menuChoiceItemLabel.text = choiceDetail[indexPath.row].rawValue
                cell.checkImageView.image = tempLevel?.rawValue == choiceDetail[indexPath.row].rawValue ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        case .toppings:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuChoiceTableViewCell.self)", for: indexPath) as? MenuChoiceTableViewCell else { return UITableViewCell() }
            if let choiceDetail = choices[category.rawValue] as? [Toppings]{
                cell.menuChoiceItemLabel.text = " \(choiceDetail[indexPath.row].rawValue)  +$\(choiceDetail[indexPath.row].price)"
                cell.checkImageView.image = toppings.contains(choiceDetail[indexPath.row]) == true ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.section]
        switch category {
        case .orderName: break
        case .capacity:
            capacity = capacityChoice[indexPath.row]
            orderChoiceDelegate?.capacityChoice(capacity: capacity)
        case .sugerLevel:
            sugarLevel = SugerLevel.allCases[indexPath.row]
            orderChoiceDelegate?.sugarLevelChoice(sugarLevel: sugarLevel)
        case .tempLevel:
            tempLevel = tempChoice[indexPath.row]
            orderChoiceDelegate?.tempLevelChoice(tempLevel: tempLevel)
        case .toppings:
            if toppings.contains(Toppings.allCases[indexPath.row]) == false{
                toppings.append(Toppings.allCases[indexPath.row])
            } else {
                toppings.remove(at: toppings.firstIndex(of: Toppings.allCases[indexPath.row])!)
            }
            orderChoiceDelegate?.toppingsChoice(toppings: toppings)
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        categories[section].rawValue
    }
}
