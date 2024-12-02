//
//  NewChatViewController.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 29/11/24.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol NewChatViewControllerDelegate: AnyObject{
    func controller(_ vc: NewChatViewController, wantChatWithUser otherUser: User)
}

class NewChatViewController: UIViewController{
    
    weak var delegate: NewChatViewControllerDelegate?
    
    private var filterUsers: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let reuseIdentfier = "UserCell"
    
    private var users: [User] = []{
        didSet{
            self.tableView.reloadData()
            print("Usuarios actualizados: \(users)")
        }
    }
    
    var inSearchMode: Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentfier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.rowHeight = 64
        
    }
    private func configureUI(){
        view.backgroundColor = .white
        title = "Search"
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
    }
    
    private func fetchUsers(){
        showLoader(true)
        UserServices.fetchUsers { users in
            self.showLoader(false)
            self.users = users
            guard let uid = Auth.auth().currentUser?.uid else {return}
            guard let index = self.users.firstIndex(where: {$0.uid == uid}) else {return}
            self.users.remove(at: index)
            print("\(users)")
        }
    }
    
    private func configureSearchController(){
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Buscar"
        navigationItem.searchController = searchController
    }
}



extension NewChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: reuseIdentfier, for: indexPath) as! UserCell
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        print("Usuario seleccionado: \(user.fullname)")
        // Dentro de NewChatViewController, cuando seleccionas un usuario:
        delegate?.controller(self, wantChatWithUser: user)
    }
}

extension NewChatViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText  = searchController.searchBar.text?.lowercased() else {return}
        filterUsers = users.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        
        print(filterUsers)
        tableView.reloadData()
    }
}

extension NewChatViewController: UISearchBarDelegate{
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}

