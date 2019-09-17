//
//  ViewController.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import UIKit

extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

protocol TodoView: class {
    
    func insertTodoItem()
    func removeTodoItem(at index: Int)
    func updateTodoItem(at index: Int)
    func reloadTodoItems()
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var textFieldViewItem: UITextField!
    
    var viewModel: TodoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableViewItems.dataSource = self
        tableViewItems.delegate = self
        
        let nib = UINib(nibName: "TodoItemTableViewCell", bundle: nil)
        tableViewItems.register(nib, forCellReuseIdentifier: "TodoItemTableViewCell")
        
        viewModel = TodoViewModel(view: self)
    }

    @IBAction func onAddItem(_ sender: UIButton) {
        
        guard let value = textFieldViewItem.text, !value.isEmpty else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.viewModel?.newTodoItem = value
            self.viewModel?.onAddTodoItem()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell", for: indexPath) as! TodoItemTableViewCell
        
        if let itemViewModel = viewModel?.items[indexPath.row] {
            cell.configure(viewModel: itemViewModel)
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel?.items[indexPath.row]
        (item as? TodoItemDelegate)?.onItemSelected()
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = self.viewModel?.items[indexPath.row]
        let actions = item?.menuItems?.map({ menuItem -> UIContextualAction in
            let action = UIContextualAction(style: .normal, title: menuItem.title) { (action, view, success: (Bool) -> Void) in
                DispatchQueue.global(qos: .userInitiated).async {
                    (menuItem as? TodoMenuItemViewDelegate)?.onMenuItemSelected()
                }
                success(true)
            }
            
            action.backgroundColor = menuItem.backgroundColor?.hexColor
            return action
        })
        
        return UISwipeActionsConfiguration(actions: actions!)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let item = self.viewModel?.items[indexPath.row]
        let actions = item?.menuItems?.map({ menuItem -> UITableViewRowAction in
            let action = UITableViewRowAction(style: .default, title: menuItem.title) { (action, indexPath) in
                DispatchQueue.global(qos: .userInitiated).async {
                    (menuItem as? TodoMenuItemViewDelegate)?.onMenuItemSelected()
                }
            }
            
            action.backgroundColor = menuItem.backgroundColor?.hexColor
            return action
        })
        
        return actions
    }
}

extension ViewController: TodoView {
    func insertTodoItem() {
        guard let items = viewModel?.items else {
            return
        }
        
        DispatchQueue.main.async {
            self.textFieldViewItem.text = self.viewModel?.newTodoItem
            self.tableViewItems.beginUpdates()
            self.tableViewItems.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        }
        
        
    }
    
    func removeTodoItem(at index: Int) {
        DispatchQueue.main.async {
            self.tableViewItems.beginUpdates()
            self.tableViewItems.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        }
    }
    
    func updateTodoItem(at index: Int) {
        DispatchQueue.main.async {
            self.tableViewItems.beginUpdates()
            self.tableViewItems.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        }
    }
    
    func reloadTodoItems() {
        DispatchQueue.main.async {
            self.tableViewItems.reloadData()
        }
    }
}

