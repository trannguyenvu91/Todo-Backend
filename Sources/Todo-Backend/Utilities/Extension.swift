//
//  Extension.swift
//  CookRecipes
//
//  Created by VuVince on 2/8/18.
//

import PerfectHTTP

//MARK: HTTPRequest
extension HTTPRequest {
    
    public func paramIntValue(name: String) -> Int? {
        if let string = param(name: name),
            let value = Int(string)
        {
            return value
        }
        return nil
    }
    
}
