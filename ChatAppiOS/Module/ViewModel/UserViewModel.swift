//
//  UserViewModel.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit

struct UserViewModel{
    let user: User
    
    var fullname: String {return user.fullname}
    var username: String {return user.username}
    
    var profileImageView: URL?{
        return URL(string: user.profileImageURL)
    }
    
    init(user: User) {
        self.user = user
    }
}

