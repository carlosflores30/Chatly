//
//  UserCell.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import Foundation

class UserCell: UITableViewCell {
    
    var viewModel: UserViewModel?{
        didSet{
            configure()
        }
    }
    private let profileImageView = CustomeImageView(width: 48, height: 48, backgroundColor: .lightGray, cornerRadius: 24)
    
    private let username  = CustomeLabel(text: "Username", labelFont: .boldSystemFont(ofSize: 17))
    private let fullname = CustomeLabel(text: "Fullname", labelColor: .lightGray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [username, fullname])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        guard let viewModel = viewModel else {return}
        self.fullname.text = viewModel.fullname
        self.username.text = viewModel.username
        self.profileImageView.sd_setImage(with: viewModel.profileImageView)
    }
    
}

