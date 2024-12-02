//
//  ConversationCell.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import Foundation

class ConversationCell: UITableViewCell{
    
    var viewModel: MessageViewModel?{
        didSet{
            configure()
        }
    }
    private let profileImageView = CustomeImageView(image: #imageLiteral(resourceName: "Google_Contacts_logo copy"), width: 60, height: 60, backgroundColor: .lightGray, cornerRadius: 30)
    
    private let fullname = CustomeLabel(text: "Fullname")
    private let recentMessage = CustomeLabel(text: "Recent message", labelColor: .lightGray)
    private let dateLabel = CustomeLabel(text: "27/11/2024", labelColor: .lightGray)
    
    private let unReadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 30, width: 30)
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [fullname, recentMessage])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 15)
        
        let stackDate = UIStackView(arrangedSubviews: [dateLabel, unReadMsgLabel])
        stackDate.axis =  .vertical
        stackDate.spacing = 7
        stackDate.alignment = .trailing
        
        addSubview(stackDate)
        stackDate.centerY(inView: profileImageView, rightAnchor: rightAnchor, paddingRight: 8)
        //addSubview(dateLabel)
        //dateLabel.centerY(inView: self, rightAnchor: rightAnchor, paddingRight: 10)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        guard let viewModel = viewModel else  {return}
        
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL)
        self.fullname.text = viewModel.fullname
        self.recentMessage.text = viewModel.messageText
        self.dateLabel.text = viewModel.timestampString
        
        self.unReadMsgLabel.text = "\(viewModel.unReadCount)"
        self.unReadMsgLabel.isHidden = viewModel.shouldHidenUnReadLabel
    }
}

