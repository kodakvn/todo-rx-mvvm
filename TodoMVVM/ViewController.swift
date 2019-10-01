//
//  ViewController.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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

class ViewController: UIViewController {
    
    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var textFieldViewItem: UITextField!
    
    var viewModel: TodoViewModel?
    
    let disposeBag = DisposeBag()
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.barStyle = UIBarStyle.black
        controller.searchBar.barTintColor = UIColor.black
        controller.searchBar.backgroundColor = UIColor.clear
        controller.searchBar.placeholder = "Search todos..."
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        tableViewItems.dataSource = self
        tableViewItems.delegate = self
        
        let nib = UINib(nibName: "TodoItemTableViewCell", bundle: nil)
        tableViewItems.register(nib, forCellReuseIdentifier: "TodoItemTableViewCell")
        
        viewModel = TodoViewModel()
        
        viewModel?.filteredItems.asObservable().bind(to: tableViewItems.rx.items(cellIdentifier: "TodoItemTableViewCell", cellType: TodoItemTableViewCell.self)) { (index, item, cell) in
            cell.configure(viewModel: item)
        }.disposed(by: disposeBag)
        
        tableViewItems.tableHeaderView = searchController.searchBar
        tableViewItems.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        
        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debug()
            .bind(to: (viewModel?.searchValue)!)
            .disposed(by: disposeBag)
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel?.items.value[indexPath.row]
        (item as? TodoItemDelegate)?.onItemSelected()
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = self.viewModel?.items.value[indexPath.row]
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
        
        let item = self.viewModel?.items.value[indexPath.row]
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

