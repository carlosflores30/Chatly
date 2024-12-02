//
//  ChatHeader.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//

import UIKit

class ChatHeader: UICollectionReusableView{
    var dateValue: String?{
        didSet{
            configure()
        }
    }
    
    private let dateLabel: CustomeLabel = {
        let label = CustomeLabel(text: "10/12/2020", labelFont: .systemFont(ofSize: 16), labelColor: .white)
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5)
        label.setDimensions(height: 30, width: 100)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dateLabel)
        dateLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        guard let dateValue = dateValue else{
            return
        }
        
        dateLabel.text = dateValue
    }
}
