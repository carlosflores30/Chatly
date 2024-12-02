//
//  AuthServices.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import FirebaseCore
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AppAuthCore

struct AuthCreadtionl{
    let email: String
    let password: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}

struct AuthCredationalEmail{
    let email: String
    let uid: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}

struct AuthServices{
    static func loginUser( withEmail email: String, withPassword password: String, completion: @escaping(AuthDataResult?, Error?) -> Void ){
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(creadtional: AuthCreadtionl, completion: @escaping(Error?) -> Void){
        FileUploader.uploadImage(image: creadtional.profileImage) { imageURL in
            Auth.auth().createUser(withEmail: creadtional.email, password: creadtional.password) { result, error in
                if let error = error {
                    print("Error creando cuenta \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else {return}
                
                let data: [String: Any] = [
                    "email": creadtional.email,
                    "username": creadtional.username,
                    "fullname": creadtional.fullname,
                    "uid": uid,
                    "profileImageURL": imageURL
                ]
                
                Collection_User.document(uid).setData(data, completion: completion)
            }
        }
    }
    static func registerWithGoogle(credtional: AuthCredationalEmail, completion: @escaping(Error?) -> Void){
        FileUploader.uploadImage(image: credtional.profileImage) { imageURL in
            let data: [String: Any] = [
                "email": credtional.email,
                "username": credtional.username,
                "fullname": credtional.fullname,
                "uid": credtional.uid,
                "profileImageURL": imageURL
            ]
            print("Guardando datos del usuario en Firestore: \(data)")
            Collection_User.document(credtional.uid).setData(data, completion: completion)
            }
        }
    }


