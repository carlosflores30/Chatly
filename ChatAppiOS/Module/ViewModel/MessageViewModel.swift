//
//  MessageViewModel.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit

struct MessageViewModel{
    let message: Message
    
    var messageText: String {return message.text}
    var messageBackgroundColor: UIColor {return message.isFromCurrentUser ? #colorLiteral(red: 0.4196078431, green: 0.831372549, blue: 0.431372549, alpha: 1) : #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9137254902, alpha: 1)}
    var messageColor: UIColor {return message.isFromCurrentUser ? .white : .black}
    
    var fullname: String {return message.fullname}
    var username: String {return message.username}
    
    var unReadCount: Int {return message.new_msg}
    var shouldHidenUnReadLabel: Bool {return message.new_msg == 0}
    
    var rightAnchorActive: Bool {return message.isFromCurrentUser}
    var leftAnchorActive: Bool {return !message.isFromCurrentUser}
    var shouldHideProfileImage: Bool {return message.isFromCurrentUser}
    
    var profileImageURL: URL? {return URL(string: message.profileImageURL)}
    
    var imageURL: URL? {return URL(string: message.imageURL)}
    var videoURL: URL? {return URL(string: message.videoURL)}
    var audioURL: URL? {return URL(string: message.audioURL)}
    
    var locationURL: URL? {
        let encodedURL = message.locationURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: encodedURL ?? "")
    }
    
    var isImageHide:  Bool {return message.imageURL == ""}
    var isTextHide: Bool {return message.imageURL != ""}
    var isVideoHide: Bool {return message.videoURL == ""}
    var isAudioHide: Bool {return message.audioURL == ""}
    var isLocationHide: Bool {return message.locationURL == ""}
    
    var timestampString: String?{
        let date = message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    init(message: Message) {
        self.message = message
    }
    
}

