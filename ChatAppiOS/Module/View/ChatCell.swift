//
//  ChatCell.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import Foundation

protocol ChatCellDelegate: AnyObject{
    func cell(wantToPlayVideo cell: ChatCell, videoURL: URL?)
    func cell(wantToShowImage cell: ChatCell, imageURL: URL?)
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool)
    func cell(wantToOpenGoogleMap cell: ChatCell, locationURL: URL?)
}

class ChatCell: UICollectionViewCell{
    
    weak var delegate: ChatCellDelegate?
    
    var viewModel: MessageViewModel?{
        didSet{
            configure()
        }
    }
    
    private let profileImageView = CustomeImageView(width: 30, height: 30, backgroundColor: .lightGray, cornerRadius: 15)
    private let dateLabel = CustomeLabel(text: "27/11/2024", labelFont: .systemFont(ofSize: 12), labelColor: .lightGray)
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9245408177, green: 0.9278380275, blue: 0.9309870005, alpha: 1)
        return view
    }()
    
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.isEditable = false
        tf.isScrollEnabled = false
        tf.text = "Sample Data"
        tf.font = .systemFont(ofSize: 16)
        return tf
    }()
    
    private lazy var postImage: CustomeImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImage))
        let iv = CustomeImageView()
        iv.isHidden = true
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var postVideo: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle(" Play Video", for: .normal)
        button.addTarget(self, action: #selector(handleVideoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postAudio: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle(" Play Audio", for: .normal)
        button.addTarget(self, action: #selector(handleAudioButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postLocation: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle(" Google Map", for: .normal)
        button.addTarget(self, action: #selector(handleLocationButton), for: .touchUpInside)
        return button
    }()
    
    var isVoicePlaying: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10 )
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        addSubview(dateLabel)
        dateLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 12)
        dateLeftAnchor.isActive = false
        
        dateRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -12)
        dateRightAnchor.isActive = false
        
        dateLabel.anchor(bottom: bottomAnchor)
        
        addSubview(postImage)
        postImage.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postVideo)
        postVideo.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postAudio)
        postAudio.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postLocation)
        postLocation.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)

    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        guard let viewModel = viewModel else {return}
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.text = viewModel.messageText
        textView.textColor = viewModel.messageColor
        
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        dateRightAnchor.isActive = viewModel.rightAnchorActive
        
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        dateLeftAnchor.isActive = viewModel.leftAnchorActive
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        
        guard let timestampString = viewModel.timestampString else {return}
        dateLabel.text = timestampString
        
        postImage.sd_setImage(with: viewModel.imageURL)
        textView.isHidden = viewModel.isTextHide
        postImage.isHidden = viewModel.isImageHide
        postVideo.isHidden = viewModel.isVideoHide
        postAudio.isHidden = viewModel.isAudioHide
        postLocation.isHidden = viewModel.isLocationHide
        
        if !viewModel.isImageHide{
            postImage.setHeight(200)
        }
    }
    
    @objc func handleVideoButton(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(wantToPlayVideo: self, videoURL: viewModel.videoURL)
    }
    
    @objc func handleImage(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(wantToShowImage: self, imageURL: viewModel.imageURL)
    }
    
    @objc func handleAudioButton(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(wantToPlayAudio: self, audioURL: viewModel.audioURL, isPlay: isVoicePlaying)
        
        isVoicePlaying.toggle()
        updateAudioButton(isPlaying: isVoicePlaying)

    }
    
    @objc func handleLocationButton(){
        guard let viewModel = viewModel else {return}
        delegate?.cell(wantToOpenGoogleMap: self, locationURL: viewModel.locationURL)
    }
    
    func updateAudioButton(isPlaying: Bool) {
            let title = isPlaying ? " Play Audio" : " Stop Audio"
            let imageName = isPlaying ? "play.fill" : "stop.fill"
            postAudio.setTitle(title, for: .normal)
            postAudio.setImage(UIImage(systemName: imageName), for: .normal)
        }
}
