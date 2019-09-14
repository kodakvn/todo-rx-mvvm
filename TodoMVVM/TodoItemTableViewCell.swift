//
//  TodoItemTableViewCell.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var txtIndex: UILabel!
    @IBOutlet weak var txtTodoItem: UILabel!
    
    func configure(viewModel: TodoItemPresentable) {
        
        txtIndex.text = viewModel.id
        txtTodoItem.text = viewModel.textValue
    }
}
