//
//  ChatViewController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import Firebase
import FirebaseFirestore
import AVKit
import AVFoundation

class ChatViewController: UICollectionViewController{
    
    var audioPlayer: AVPlayer?
    var audioPlayerLayer: AVPlayerLayer?
    var currentPlayingCell: ChatCell?

    private let reuseIdentifer = "ChatCell"
    private let chatHeaderIdentifer = "ChatHeader"
    
    private var messages = [[Message]](){
        didSet{
            self.emptyView.isHidden = !messages.isEmpty
        }
    }
    
    private lazy var customeInputView: CustomeInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = CustomeInputView(frame: frame)
        iv.delegate = self
        return iv
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    private let emptyLabel = CustomeLabel(text: "Las conversaciones son nuevas y están vacías", labelColor: .yellow)
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    
    private lazy var attachAlert: UIAlertController = {
        let alert = UIAlertController(title: "Attach File", message: "Select the button you want to attach from", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.handleCamera()
        }))
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.handleGallery()
        }))
        alert.addAction(UIAlertAction(title: "Ubicacion", style: .default, handler: { _ in
            self.present(self.locationAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        return alert
    }()
    
    private lazy var locationAlert: UIAlertController = {
        let alert = UIAlertController(title: "Compartir ubicacion", message: "Seleccione el boton para compartir tu ubicacion", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ubicacion actual", style: .default, handler: { _ in
            self.handleCurrentLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { _ in
            self.handleGoogleMap()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    var currentUser: User
    var otherUser: User
    
    init(currentUser: User,otherUser: User){
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: chatHeaderIdentifer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.markReadAllMsg()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMsg()
    }

    override var inputAccessoryView: UIView?{
        get {return customeInputView}
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    private func configureUI(){
        title = otherUser.fullname
        collectionView.backgroundColor = .white
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifer)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 70, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
        
    }
    
    private func fetchMessages(){
        MessageServices.fetchMessages(otherUser: otherUser) { messages in
            
            let groupMessages = Dictionary(grouping: messages) { (element) -> String in
                let dateValue = element.timestamp.dateValue()
                let stringDateValue = self.stringValue(forDate: dateValue)
                return stringDateValue ?? ""
            }
            
            self.messages.removeAll()
            
            let sortedKeys = groupMessages.keys.sorted(by: {$0 < $1})
            sortedKeys.forEach { key in
                let values = groupMessages[key]
                self.messages.append(values ?? [])
            }
            
            self.collectionView.reloadData()
            self.collectionView.scrollToLastItem()
            }
            
        }
    
    private func markReadAllMsg(){
        MessageServices.markReadAllMsg(otherUser: otherUser)
    }
}
    
extension ChatViewController{
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            guard let firstMessage = messages[indexPath.section].first else {return UICollectionReusableView()}
            
            let dateValue = firstMessage.timestamp.dateValue()
            let stringValue = stringValue(forDate: dateValue)
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: chatHeaderIdentifer, for: indexPath) as! ChatHeader
            cell.dateValue = stringValue
            return cell
        }
        return UICollectionReusableView()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! ChatCell
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.delegate = self
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = ChatCell(frame: frame)
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimeSize = cell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimeSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ChatViewController: CustomeInputViewDelegate{
    
    func inputViewForAttach(_ view: CustomeInputView) {
        present(attachAlert, animated: true)
    }
    
    func inputView(_ view: CustomeInputView, wantUploadMessage message: String) {
        MessageServices.fetchSingleRecentMsg(otherUser: otherUser) { [self] unReadCount in
            MessageServices.uploadMessage(message: message, currentUser: currentUser, otherUser: otherUser, unReadCount: unReadCount + 1) { _ in
                self.collectionView.reloadData()
            }
        }
        view.clearTextView()
    }
    
    
    func inputViewForAudio(_ view: CustomeInputView, audioURL: URL) {
        self.showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { audioString in
            MessageServices.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadCount in
                MessageServices.uploadMessage(audioURL: audioString ,currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount + 1) { error in
                    self.showLoader(false)
                    if let error = error{
                        print("\(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
}
