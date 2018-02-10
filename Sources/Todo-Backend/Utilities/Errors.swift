//
//  Extension.swift
//  CookRecipes
//
//  Created by VuVince on 2/8/18.
//

import StORM

protocol BackendError: Error {
    var description: String { get }
    var code: Int { get }
}

enum RountingError: Int, BackendError {
    
    case missingToken = 100
    case missingParam = 101
    
    var code: Int {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .missingParam:
            return "Missing param"
        case .missingToken:
            return "Missing token"
        }
    }
    
}

enum DatabaseError: Int, BackendError {
    case tokenInvalid = 200
    
    var code: Int {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .tokenInvalid:
            return "Token Invalid"
        }
    }
    
}

extension StORMError {
    
    var code: Int {
        return 300
    }
    
}

extension Error {
    var getMessage: String {
        var errMessage = localizedDescription
        if let err = self as? BackendError {
            errMessage = err.description
        } else if let err = self as? StORMError {
            errMessage = err.string()
        }
        return errMessage
    }
    
    var getCode: Int {
        var code = 0
        if let err = self as? BackendError {
            code = err.code
        } else if let err = self as? StORMError {
            code = err.code
        }
        return code
    }
    
}
