//
//  LoginViewController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import Foundation
import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController{
    
    var viewModel = LoginViewModel()
    
    private let welcomeLable = CustomeLabel(text: "HOLA, BIENVENIDO A CHATLY", labelFont: .boldSystemFont(ofSize: 20))
    
    private let profileImageView = CustomeImageView(image: #imageLiteral(resourceName: "iTunesArtwork"), width: 100, height: 100)
    
    private let emailTF = CustomeTextFeild(placeholder: "Email", keyboardType: .emailAddress)
    private let passwordTF = CustomeTextFeild(placeholder: "Password", isSecure: true)

    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
        button.blackButton(buttonText: "Login")
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attrributedText(firstString: "No tienes cuenta?", secoundString: "Sign Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        return button
    }()
    
    private let contLable = CustomeLabel(text: "o continua con Google ", labelColor: .lightGray)

    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleGoogleSignInVC), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextFeild()
    }
    
    private func configureUI(){
        view.backgroundColor = .white
        
        view.addSubview(welcomeLable)
        welcomeLable.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLable.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: welcomeLable.bottomAnchor, paddingTop: 20)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        
        view.addSubview(contLable)
        contLable.centerX(inView: view, topAnchor: loginButton.bottomAnchor, paddingTop: 30)
        
        view.addSubview(googleButton)
        googleButton.centerX(inView: view, topAnchor: contLable.bottomAnchor, paddingTop: 12)
    }
    
    private func configureForTextFeild(){
        emailTF.addTarget(self, action: #selector(handleTextChanged(sender: )), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextChanged(sender: )), for: .editingChanged)
    }
    
    @objc func handleLoginVC(){
        guard let email = emailTF.text?.lowercased() else {return}
        guard let password = passwordTF.text else {return}
        
        showLoader(true)
        
        AuthServices.loginUser(withEmail: email, withPassword: password) { result, error in
            self.showLoader(false)
            if let error = error{
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.showLoader(false)
            print("Usuario logueado")
            self.navToConversationVC()
        }
    }
    
    @objc func handleSignUpButton(){
        let controller = RegisterViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleSignInVC(){
        showLoader(true)
        setupGoogle()
    }
    
    @objc func handleTextChanged(sender: UITextField){
        sender == emailTF ? (viewModel.email = sender.text) : (viewModel.password = sender.text)
        updateForm()
    }
    
    private func updateForm(){
        loginButton.isEnabled = viewModel.formIsFaild
        loginButton.backgroundColor = viewModel.backgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
    
    func navToConversationVC(){
        guard let uid  = Auth.auth().currentUser?.uid else {return}
        showLoader(true)
        UserServices.fetchUser(uid: uid) { user in
            self.showLoader(false)
            print("User \(user)")
            let controller = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: RegisterVC_Delegate{
    func didSuccCreateAccount(_ vc: RegisterViewController) {
        vc.navigationController?.popViewController(animated: true)
        showLoader(false)
        navToConversationVC()
    }
}
