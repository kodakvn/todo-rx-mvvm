//
//  TodoItem.swift
//  TodoMVVM
//
//  Created by KODAK on 9/18/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import RealmSwift

class TodoItem: Object {
    @objc dynamic var todoId: Int = 0
    @objc dynamic var todoValue: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date?
    @objc dynamic var deletedAt: Date?
    
    override static func primaryKey() -> String? {
        return "todoId"
    }
}
