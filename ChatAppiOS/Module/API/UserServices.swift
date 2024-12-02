//
//  UserServices.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

struct UserServices{
    static func fetchUser(uid: String, completion: @escaping(User) -> Void){
        Collection_User.document(uid).getDocument{(snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void){
        Collection_User.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {return}
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            completion(users)
        }
    }
    
    static func setNewUserData(data: [String: Any], completion: @escaping(Error?) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Collection_User.document(uid).updateData(data, completion: completion)
    }
}
