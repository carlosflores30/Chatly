//
//  LoginViewModel.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit

protocol AuthLoginModel{
    var formIsFaild: Bool {get}
    var backgroundColor: UIColor {get}
    var buttonTitleColor: UIColor {get}
}

struct LoginViewModel: AuthLoginModel{
    var email: String?
    var password: String?
    
    var formIsFaild: Bool{
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var backgroundColor: UIColor{
        return formIsFaild ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor{
        return formIsFaild ? (UIColor.white): (UIColor(white: 1, alpha: 0.7))
    }
}

struct RegViewModel: AuthLoginModel{
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsFaild:  Bool{
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var backgroundColor: UIColor{
        return formIsFaild ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor{
        return formIsFaild ? (UIColor.white): (UIColor(white: 1, alpha: 0.7))
    }
}

