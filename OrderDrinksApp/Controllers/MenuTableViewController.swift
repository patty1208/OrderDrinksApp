//
//  MenuTableViewController.swift
//  OrderDrinksApp
//
//  Created by 林佩柔 on 2021/11/22.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var menuRecords = [MenuRecord]()
    var menuByCategory: [String: [MenuRecord]] = [:]
    var categories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MenuController.shared.fetchMenuRecords{ (result) in
            switch result {
            case .success(let menuRecords):
                self.updateUI(with: menuRecords)
                MenuController.shared.menuResponse.records = menuRecords
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Menu Items for \(self.menuRecords)")
            }
        }
    }

    
    func updateUI(with menuRecords: [MenuRecord]) {
        DispatchQueue.main.async {
            self.menuRecords = menuRecords
            self.menuByCategory = Dictionary(grouping: self.menuRecords) { (record) -> String in
                return record.fields.category }
            self.categories = MenuController.shared.categoryByMenu
            self.tableView.reloadData()
        }
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recordsByCategory = menuByCategory[categories[section]] else { return 0 }
        return recordsByCategory.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuRecord", for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        
        let category = categories[indexPath.section]
        guard let menuRecordByCategory = menuByCategory[category] else { return UITableViewCell() }
        let menuRecord = menuRecordByCategory[indexPath.row]
        
        cell.aboutDrinkLabel.text = "\(menuRecord.fields.drinkName)"
        cell.recommendImageView.image = menuRecord.fields.isRecommend == "true" ? UIImage(systemName: "star.fill") : UIImage()
        let temp = menuRecord.fields.onlyHot == "true" ? "hot" : menuRecord.fields.onlyCold == "true" ? "cold" : "both"
        cell.onlyColdOrHot.image = temp == "hot" ? UIImage(named: "hot tea") : temp == "cold" ? UIImage(named: "ice cube") : UIImage()
        
        cell.recommendImageView.tintColor = UIColor(red: 247/255, green: 205/255, blue: 70/255, alpha: 1)
        
        // 點選cell的背景顏色
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 84/255, green: 24/255, blue: 38/255, alpha: 0.2)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        let titleLabel = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: tableView.bounds.size.width - 20, height: 30))
        titleLabel.text = categories[section]
        titleLabel.textColor = UIColor.white
        headerView.addSubview(titleLabel)
        return headerView
    }
    
     // MARK: - Navigation
    @IBSegueAction func passMenu(_ coder: NSCoder) -> MenuItemDetailViewController? {
        guard let section = tableView.indexPathForSelectedRow?.section,
              let row = tableView.indexPathForSelectedRow?.row,
              let recordsByCategory = menuByCategory[categories[section]] else {
                  return MenuItemDetailViewController(coder: coder) }
        let controller = MenuItemDetailViewController(coder: coder, menuRecord: recordsByCategory[row])
        controller?.delegate = self
        return controller
    }
}

extension MenuTableViewController: MenuDelgate {
    
    func updateMenuListUIToNonSelected() {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: false)
    }
    
    
}
