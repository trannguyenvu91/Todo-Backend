//
//  MDDatabase.swift
//  CookRecipes
//
//  Created by VuVince on 2/3/18.
//

import Foundation
import StORM
import MySQLStORM
import PerfectTurnstileMySQL

class MDDatabase: NSObject {
    
    static let share = MDDatabase()
    
    func startPostgresConector() {
        // Set the connection properties for the MySQL Server
        // Change to suit your specific environment
        MySQLConnector.host        = "127.0.0.1"
        MySQLConnector.username    = "CookRecipesSQL"
        MySQLConnector.password    = "CookRecipesSQL"
        MySQLConnector.database    = "CookRecipesSQL"
        MySQLConnector.port        = 3306
        
        let todoItem = MDTodoItem()
        try? todoItem.setup()
    }
    
}

//MARK: Todo_Items
extension MDDatabase {
    
    func getItems(forToken token: String) throws -> [MDTodoItem] {
        var items = [MDTodoItem]()
        let getObj = MDTodoItem()
        let user = try getUserID(forToken: token)
        try getObj.select(whereclause: "associatedUser = ?", params: [user], orderby: ["id"])
        items.append(contentsOf: getObj.rows())
        return items
    }
    
    func getItem(forID id: Int, forToken token: String) throws -> MDTodoItem {
        let getObj = MDTodoItem()
        try getObj.get(id)
        try validate(token: token, forItem: getObj)
        return getObj
    }
    
    func countItems(forToken token: String) throws -> Int {
        var count = 0
        let getObj = MDTodoItem()
        let userID = try getUserID(forToken: token)
        let rows = try getObj.sqlRows("SELECT COUNT(*) FROM todo_items WHERE associatedUser = ?", params: [userID])
        for row in rows {
            if let result = row.data["COUNT(*)"] as? Int64 {
                count = Int(result)
                break
            }
        }
        return count
    }
    
    func create(item: String, due: String?, forToken token: String) throws -> MDTodoItem {
        let getObj = MDTodoItem()
        getObj.item = item
        let userID = try getUserID(forToken: token)
        getObj.associatedUser = userID
        if let value = due {
            getObj.due = value
        }
        try getObj.save(set: { (id) in
            getObj.id = id as! Int
        })
        return getObj
    }
    
    func update(item obj: MDTodoItem, completed: Int?, due: String?, newName name: String?, forToken token: String) throws -> MDTodoItem {
        try validate(token: token, forItem: obj)
        obj.update(completed: completed, due: due, newName: name)
        try obj.update(cols: ["completed","due", "item"], params: [obj.completed, "\(obj.due)", "\(obj.item)"], idName: "id", idValue: obj.id)
        return obj
    }
    
    func delete(item obj: MDTodoItem, forToken token: String) throws -> Bool {
        try validate(token: token, forItem: obj)
        var deleted = false
        try obj.delete()
        deleted = true
        return deleted
    }
    
}

//MARK: User
extension MDDatabase {
    
    func validate(token: String, forItem item: MDTodoItem) throws {
        let userID = try getUserID(forToken: token)
        guard userID == item.associatedUser else {
            throw DatabaseError.tokenInvalid
        }
    }
    
    func getUserID(forToken token: String) throws -> String {
        var id: String?
        let getUser = AccessTokenStore()
        let rows = try getUser.sqlRows("SELECT userid FROM tokens WHERE token LIKE ?", params: [token])
        for row in rows {
            if let userID = row.data["userid"] as? String {
                id = userID
                break
            }
        }
        guard let userID = id else {
            throw DatabaseError.tokenInvalid
        }
        return userID
    }
    
    func update(token: String) throws -> Int {
        let getUser = AccessTokenStore()
        let now = MDConstant.now()
        let _ = try getUserID(forToken: token)
        try getUser.update(cols: ["idle", "updated"], params: [MDConstant.tokenIdleTime, now], idName: "token", idValue: token)
        let expiredDate = now + MDConstant.tokenIdleTime
        return expiredDate
    }
    
}
