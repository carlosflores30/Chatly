//
//  ProfileCell.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 2/12/24.
//

import UIKit

class ProfileCell: UITableViewCell{
    
    var viewModel: ProfileViewModel?{
        didSet{
            configure()
        }
    }
    
    private let titleLabel = CustomeLabel(text: "Name", labelColor: .red)
    private let userLabel = CustomeLabel(text: "Oprah")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, userLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        guard let viewModel = viewModel else {return}
        
        titleLabel.text = viewModel.fieldTitle
        userLabel.text = viewModel.optionType
    }
}
