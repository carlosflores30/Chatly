//
//  EditProfileViewController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 2/12/24.
//

import UIKit

class EditProfileViewController: UIViewController{
    
    private let user: User
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Editar Perfil", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImageView: CustomeImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        let iv = CustomeImageView(width: 125, height: 125, backgroundColor: .lightGray, cornerRadius: 125 / 2)
        iv.addGestureRecognizer(tap)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let fullnamelbl = CustomeLabel(text: "Fullname", labelColor: .red)
    private let fullnametxt = CustomeTextFeild(placeholder: "Fullname")
    
    private let usernamelbl = CustomeLabel(text: "Username", labelColor: .red)
    private let usernametxt = CustomeTextFeild(placeholder: "Username")
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    var selectImage: UIImage?
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProfileData()
    }
    
    private func configureUI(){
        view.backgroundColor = .white
        
        title = "Editar Perfil"
        view.addSubview(editButton)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 12)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: editButton.bottomAnchor, paddingTop: 10)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [fullnamelbl, fullnametxt, usernamelbl, usernametxt])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        fullnametxt.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        usernametxt.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        
    }
    
    private func configureProfileData(){
        fullnametxt.text = user.fullname
        usernametxt.text = user.username
        
        profileImageView.sd_setImage(with: URL(string: user.profileImageURL))
    }
    
    @objc func handleSubmitProfile(){
        guard let fullname = fullnametxt.text  else {return}
        guard let username = usernametxt.text  else {return}
        showLoader(true)
        if selectImage == nil{
            let params = [
                "fullname": fullname,
                "username": username
            ]
            updateUser(params: params)
        } else {
            guard let selectImage = selectImage else {return}
            FileUploader.uploadImage(image: selectImage) { imageURL in
                let params = [
                    "fullname": fullname,
                    "username": username,
                    "profileImageURL": imageURL
                ]
                self.updateUser(params: params)
            }
        }
    }
    
    @objc func handleImageTap(){
        present(imagePicker, animated: true)
    }
    
    private func updateUser(params: [String: Any]){
        UserServices.setNewUserData(data: params) { _ in
            self.showLoader(false)
            NotificationCenter.default.post(name: .userProfile, object: nil)
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        self.selectImage = image
        self.profileImageView.image = image
        
        dismiss(animated: true)
    }
}
