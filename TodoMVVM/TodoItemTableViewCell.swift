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
        let attributedString = NSMutableAttributedString(string: viewModel.textValue!)
        
        if viewModel.isDone! {
            let range = NSMakeRange(0, attributedString.length)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.lightGray, range: range)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
        }
        
        txtTodoItem.attributedText = attributedString
    }
}
