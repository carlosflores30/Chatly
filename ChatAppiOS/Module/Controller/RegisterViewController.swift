//
//  RegisterViewController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol RegisterVC_Delegate: AnyObject{
    func didSuccCreateAccount(_ vc: RegisterViewController)
}

class RegisterViewController: UIViewController{
    
    weak var delegate: RegisterVC_Delegate?
    
    var viewModel = RegViewModel()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attrributedText(firstString: "Ya tienes una cuenta?", secoundString: "Login Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var plushPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.setDimensions(height: 140, width: 140)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handlePlushButton), for: .touchUpInside)
        return button
    }()
    
    private let emailTF = CustomeTextFeild(placeholder: "Email", keyboardType: .emailAddress)
    private let passwordTF = CustomeTextFeild(placeholder: "Password", isSecure: true)
    private let fullnameTF = CustomeTextFeild(placeholder: "Fullname")
    private let usernameTF = CustomeTextFeild(placeholder: "Username")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.blackButton(buttonText: "Sign in")
        button.addTarget(self, action: #selector(handleSigninUpVC), for: .touchUpInside)
        return button
    }()
    
    private var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextFeild()
    }
    
    private func configureUI(){
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
        view.addSubview(plushPhotoButton)
        plushPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, fullnameTF, usernameTF, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: plushPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
    }
    
    private func configureTextFeild(){
        emailTF.addTarget(self, action: #selector(handleTextFeild(sender: )), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextFeild(sender: )), for: .editingChanged)
        fullnameTF.addTarget(self, action: #selector(handleTextFeild(sender: )), for: .editingChanged)
        usernameTF.addTarget(self, action: #selector(handleTextFeild(sender: )), for: .editingChanged)
    }
    
    @objc func handleAlreadyHaveAccountButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePlushButton(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc func handleSigninUpVC(){
        guard let email = emailTF.text?.lowercased() else {return}
        guard let password = passwordTF.text else {return}
        guard let username = usernameTF.text?.lowercased() else {return}
        guard let fullname = fullnameTF.text else {return}
        guard let profileImage = profileImage else {return}
        
        let creadtional = AuthCreadtionl(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage)
        
        showLoader(true)
        
        AuthServices.registerUser(creadtional: creadtional) { error in
            self.showLoader(false)
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            
            self.delegate?.didSuccCreateAccount(self)
        }
    }
    
    @objc func handleTextFeild(sender: UITextField){
        if sender == emailTF{
            viewModel.email = sender.text
        } else if sender == passwordTF{
            viewModel.password = sender.text
        } else if sender == fullnameTF{
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        
        updateForm()
    }
    
    private func updateForm(){
        signUpButton.isEnabled = viewModel.formIsFaild
        signUpButton.backgroundColor = viewModel.backgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

extension RegisterViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        
        self.profileImage = selectedImage
        
        plushPhotoButton.layer.cornerRadius = plushPhotoButton.frame.width / 2
        plushPhotoButton.layer.masksToBounds = true
        plushPhotoButton.layer.borderColor = UIColor.black.cgColor
        plushPhotoButton.layer.borderWidth = 2
        plushPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

