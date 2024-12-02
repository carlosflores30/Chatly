//
//  Message.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit
import Firebase
import FirebaseAuth

struct Message{
    let text: String
    let fromID: String
    let toID: String
    let timestamp: Timestamp
    let username: String
    let fullname: String
    let profileImageURL: String
    let imageURL: String
    let videoURL: String
    let audioURL: String
    let locationURL: String
    
    var isFromCurrentUser: Bool
    
    var chatPartnerID: String {return isFromCurrentUser ? toID : fromID}
    
    let new_msg: Int
    
    init(dictionary: [String: Any]){
        self.text = dictionary["text"] as? String ?? ""
        self.fromID = dictionary["fromID"] as? String ?? ""
        self.toID = dictionary["toID"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isFromCurrentUser = fromID == Auth.auth().currentUser?.uid
        self.new_msg = dictionary["new_msg"] as? Int ?? 0
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.videoURL = dictionary["videoURL"] as? String ?? ""
        self.audioURL = dictionary["audioURL"] as? String ?? ""
        self.locationURL = dictionary["locationURL"] as? String ?? ""
    }
}

