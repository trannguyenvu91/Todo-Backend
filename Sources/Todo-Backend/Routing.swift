//
//  Routing.swift
//  CookRecipes
//
//  Created by VuVince on 2/6/18.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import StORM

struct RoutingPath {
    let login = "/api/v1/login"
    let register = "/api/v1/register"
    let count = "/api/v1/count"
    let getAll = "/api/v1/get/all"
    let create = "/api/v1/create"
    let update = "/api/v1/update"
    let delete = "/api/v1/delete"
    let extendToken = "/api/v1/extendToken"
}

//MARK: Handlers
class Routing {
    
    var getRoutes: [Route] {
        get {
            return [
                Route(method: .get, uri: routePaths.count, handler: countItems),
                Route(method: .get, uri: routePaths.getAll, handler: getAllItems),
                Route(method: .post, uri: routePaths.create, handler: createItem),
                Route(method: .post, uri: routePaths.update, handler: editItem),
                Route(method: .delete, uri: routePaths.delete, handler: deleteItem),
                Route(method: .post, uri: routePaths.extendToken, handler: extendValidation)
            ]
        }
    }
    
    func countItems(request: HTTPRequest, response: HTTPResponse) {
        guard let token = validateToken(request: request, response: response) else { return }
        do {
            let count = try MDDatabase.share.countItems(forToken: token)
            returnJOSN(message: "success", data: ["count": count], in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
    func getAllItems(request: HTTPRequest, response: HTTPResponse) {
        guard let token = validateToken(request: request, response: response) else { return }
        do {
            let items = try MDDatabase.share.getItems(forToken: token)
            returnJOSN(message: "success", data: ["items": items.map{$0.asJSON()}], in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
    func createItem(request: HTTPRequest, response: HTTPResponse) {
        guard let token = validateToken(request: request, response: response) else { return }
        guard let name = request.param(name: "item"), let due = request.param(name: "due") else {
            badRequest(response: response, error: RountingError.missingParam)
            return
        }
        do {
            let item = try MDDatabase.share.create(item: name, due: due, forToken: token)
            returnJOSN(message: "success", data: ["item": item.asJSON()], in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
    func editItem(request: HTTPRequest, response: HTTPResponse) {
        guard let token = validateToken(request: request, response: response) else { return }
        guard let name = request.param(name: "item"),
            let due = request.param(name: "due"),
            let id = request.paramIntValue(name: "id"),
            let completed = request.paramIntValue(name: "completed") else {
                badRequest(response: response, error: RountingError.missingParam)
                return
        }
        do {
            let item = try MDDatabase.share.getItem(forID: id, forToken: token)
            let _ = try MDDatabase.share.update(item: item, completed: completed, due: due, newName: name, forToken: token)
            returnJOSN(message: "success", data: ["item": item.asJSON()], in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
    func deleteItem(request: HTTPRequest, response: HTTPResponse) {
        guard let token = validateToken(request: request, response: response) else { return }
        guard let id = request.paramIntValue(name: "id") else {
            badRequest(response: response, error: RountingError.missingParam)
            return
        }
        do {
            let item = try MDDatabase.share.getItem(forID: id, forToken: token)
            let _ = try MDDatabase.share.delete(item: item, forToken: token)
            returnJOSN(message: "success", data: nil, in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
    func extendValidation(request: HTTPRequest, response: HTTPResponse)  {
        guard let token = validateToken(request: request, response: response) else { return }
        do {
            let expiredDate = try MDDatabase.share.update(token: token)
            returnJOSN(message: "success", data: ["expiredDate": expiredDate], in: response)
        } catch {
            badRequest(response: response, error: error)
        }
    }
    
}

//MARK: Utilities
extension Routing {
    
    func validateToken(request: HTTPRequest, response: HTTPResponse) -> String? {
        guard let header = request.header(.authorization), let token = parseToken(fromHeader: header) else {
            badRequest(response: response, error: RountingError.missingToken)
            return nil
        }
        return token
    }
    
    func returnJOSN(message: String, data: Any?, in response:HTTPResponse) {
        var body = JSON()
        body["message"] = message
        if let dataValue = data {
            body["data"] = dataValue
        }
        do {
            try response.setHeader(.contentType, value: "application/json")
                .setBody(json: body)
                .completed()
        } catch {
            print("Bad request error: \(error) \(error.localizedDescription)")
            response.completed(status: .badRequest)
        }
    }
    
    func badRequest(response: HTTPResponse, error: Error) {
        let errMessage = error.getMessage
        let errCode = error.getCode
        
        do {
            try response.setHeader(.contentType, value: "application/json")
                .setBody(json: ["error":errMessage, "code": errCode])
                .completed()
        } catch {
            print("Bad request error: \(error) \(error.localizedDescription)")
            response.completed(status: .badRequest)
        }
    }
    
    func parseToken(fromHeader header: String) -> String? {
        if let range = header.range(of: MDConstant.tokenPrefix) {
            return header.replacingCharacters(in: range, with: "")
        }
        return nil
    }
    
}

