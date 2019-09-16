//
//  ViewController.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import UIKit

protocol TodoView: class {
    
    func insertTodoItem()
    
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
        
        viewModel?.newTodoItem = value
        viewModel?.onAddTodoItem()
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
}

extension ViewController: TodoView {
    func insertTodoItem() {
        guard let items = viewModel?.items else {
            return
        }
        
        textFieldViewItem.text = viewModel?.newTodoItem
        tableViewItems.beginUpdates()
        tableViewItems.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
        tableViewItems.endUpdates()
    }
}

