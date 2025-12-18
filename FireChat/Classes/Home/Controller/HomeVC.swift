//
//  HomeVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class HomeVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchCancelBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noFriendLabel: UILabel!
    
    
    // MARK: - Properties
    fileprivate lazy var mainFriendsList = [UserDataModel]()
    fileprivate lazy var searchedFriendsList = [UserDataModel]()
    fileprivate let db = Firestore.firestore()
    
    fileprivate let spinner = HVDOverlayExtended.spinnerOverlay()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        self.setControlsProperty()
        self.addRightNavBarButton()
        
        self.fetchFriends()
        
        getDefaultUserName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.updateSearchContainerUI()
        }
    }
    
    fileprivate func setControlsProperty() {
        
        // View Background
        self.view.backgroundColor = .getBgColor()
        
        // Search Container
        self.searchContainer.backgroundColor = .clear
        self.searchContainer.addRadiusWithBorder(radius: 12, border: 1)
        self.searchContainer.layer.borderColor = UIColor.getUnSelectedBorderColor().cgColor
        self.searchContainer.clipsToBounds = true
        
        // Search Icon
        self.searchIcon.image = UIImage(named: "SearchIcon")?.withRenderingMode(.alwaysTemplate)
        self.searchIcon.tintColor = .getUnSelectedBorderColor()
        
        // Search TextField
        self.searchTextField.backgroundColor = .getClearColour()
        self.searchTextField.textColor = .getTextColor()
        self.searchTextField.tintColor = .getTextColor()
        self.searchTextField.setTextFieldFont()
        self.searchTextField.textAlignment = .left
        self.searchTextField.inputAccessoryView = UIView()
        self.searchTextField.keyboardType = .asciiCapable
        self.searchTextField.autocapitalizationType = .words
        self.searchTextField.returnKeyType = .done
        self.searchTextField.autocorrectionType = .no
        self.searchTextField.delegate = self
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search by name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.getPlaceholderTextColor()])
        
        self.searchTextField.text = ""
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        
        // Search Cancel Button
        self.searchCancelBtn.backgroundColor = .getClearColour()
        self.searchCancelBtn.setImage(UIImage(named: "CloseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.searchCancelBtn.tintColor = .getSelectedBorderColor()
        self.searchCancelBtn.isHidden = true
        
        // Tableview
        self.tableView.backgroundColor = .getClearColour()
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.tag = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.tableFooterView = UIView().addTableFooter(height: UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : 20)
        self.tableView.tableFooterView?.backgroundColor = .getClearColour()
        
        // No Friend Label
        self.noFriendLabel.backgroundColor = .getClearColour()
        self.noFriendLabel.textColor = .getTextColor()
        self.noFriendLabel.font = .systemFont(ofSize: 12, weight: .medium)
        self.noFriendLabel.textAlignment = .center
        self.noFriendLabel.numberOfLines = 1
        self.noFriendLabel.lineBreakMode = .byTruncatingTail
        self.noFriendLabel.text = Constants.Generic.NoFriendFound
        self.noFriendLabel.isHidden = true
    }
    
    override func reloadAppData() {
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fetchFriends()
        }
    }
}


//MARK: - Call Back
extension HomeVC {
    
    fileprivate func addRightNavBarButton() {
        
        let addFriendBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addFriendBtn.setImage(UIImage(named: "PlusIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addFriendBtn.backgroundColor = .getButtonBgColor()
        addFriendBtn.tintColor = .getButtonTextColor()
        addFriendBtn.layer.cornerRadius = addFriendBtn.bounds.width / 2.0
        addFriendBtn.clipsToBounds = true
        addFriendBtn.showsTouchWhenHighlighted = false
        addFriendBtn.adjustsImageWhenHighlighted = false
        addFriendBtn.adjustsImageWhenDisabled = false
        addFriendBtn.startAnimatingPressActions()
        addFriendBtn.addTarget(self, action: #selector(self.addFriendBtnTouch(_:)), for: .touchUpInside)
        
        let logoutBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        logoutBtn.setImage(UIImage(named: "LogoutIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        logoutBtn.backgroundColor = .getButtonBgColor()
        logoutBtn.tintColor = .getButtonTextColor()
        logoutBtn.layer.cornerRadius = logoutBtn.bounds.width / 2.0
        logoutBtn.clipsToBounds = true
        logoutBtn.showsTouchWhenHighlighted = false
        logoutBtn.adjustsImageWhenHighlighted = false
        logoutBtn.adjustsImageWhenDisabled = false
        logoutBtn.startAnimatingPressActions()
        logoutBtn.addTarget(self, action: #selector(self.logoutBtnTouch(_:)), for: .touchUpInside)
        
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: addFriendBtn),
                                                    UIBarButtonItem(customView: logoutBtn)], animated: true)
    }
    
    fileprivate func showSpinner() {
        self.spinner?.show(on: APPDELEOBJ.window)
    }
    
    fileprivate func hideSpinner() {
        self.spinner?.dismiss()
    }
    
    fileprivate func searchData() {
        
        self.tableView.backgroundView = nil
        
        self.searchedFriendsList = self.mainFriendsList
        
        if let text = self.searchTextField.text, !text.isEmpty {
            
            self.searchedFriendsList = self.mainFriendsList.filter({
                $0.firstName?.range(of: text, options: .caseInsensitive) != nil ||
                $0.lastName?.range(of: text, options: .caseInsensitive) != nil })
        }
        
        if !self.searchedFriendsList.isEmpty {
            
            self.tableView.isHidden = false
            self.noFriendLabel.isHidden = true
            
        } else {
            
            self.noFriendLabel.isHidden = false
            self.tableView.isHidden = true
        }
        
        self.tableView.reloadData()
        self.tableView.contentOffset = .zero
    }
    
    fileprivate func updateSearchContainerUI() {
        
        if let text = self.searchTextField.text, !text.isEmpty {
            self.searchCancelBtn.isHidden = false
            self.searchContainer.layer.borderColor = UIColor.getSelectedBorderColor().cgColor
            self.searchIcon.tintColor = .getSelectedBorderColor()
        } else {
            self.searchCancelBtn.isHidden = true
            self.searchContainer.layer.borderColor = UIColor.getUnSelectedBorderColor().cgColor
            self.searchIcon.tintColor = .getUnSelectedBorderColor()
        }
    }
    
    fileprivate func resignAllTextFields() {
        self.searchTextField?.resignFirstResponder()
    }
}


// MARK: - Firebase Chat Method
extension HomeVC {
    
    fileprivate func fetchUsers() {
        
        self.showSpinner()
        
        var usersList = [UserDataModel]()
        
        self.db.collection("users").order(by: "createdAt", descending: false).getDocuments { [weak self] snapshot, error in
            
            guard let self = self else { return }
            
            if let error = error {
                toastMessage(messageStr: "Error in fetching user list: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                
                if doc.documentID != getDefaultUserId() {
                    
                    var dictUser = UserDataModel()
                    dictUser.uid = doc.documentID
                    
                    let data = doc.data()
                    dictUser.firstName = data["firstName"] as? String ?? ""
                    dictUser.lastName = data["lastName"] as? String ?? ""
                    dictUser.email = data["email"] as? String ?? ""
                    
                    usersList.append(dictUser)
                }
            }
            
            if !usersList.isEmpty {
                
                let userListPopupVC = getStoryBoard(identifier: "UserListPopupVC", storyBoardName: Constants.Storyboard.Main) as! UserListPopupVC
                userListPopupVC.mainUsersList = usersList
                userListPopupVC.userListDelegate = self
                let navController = UINavigationController(rootViewController: userListPopupVC)
                navController.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(navController, animated: false, completion: nil)
                
            } else {
                toastMessage(messageStr: Constants.Generic.NoUserFound)
            }
            
            self.hideSpinner()
        }
    }
    
    fileprivate func fetchFriends() {
        
        if !isConnectedToInternet() { return }
        
        self.showSpinner()
        
        self.mainFriendsList.removeAll()
        self.searchedFriendsList.removeAll()
        
        self.tableView.reloadData()
        
        let currentUserId = getDefaultUserId()
        self.db.collection("users").document(currentUserId).collection("friends").getDocuments { [weak self] snapshot, error in
            
            guard let self = self else { return }
            
            if let error = error {
                toastMessage(messageStr: "Error in fetching user list: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let friendIds = documents.map { $0.documentID }
            let group = DispatchGroup()
            
            for friendId in friendIds {
                
                group.enter()
                
                self.db.collection("users").document(friendId).getDocument { [weak self] docSnapshot, error in
                    
                    defer { group.leave() }
                    
                    if let data = docSnapshot?.data() {
                        
                        var dictUser = UserDataModel()
                        dictUser.uid = docSnapshot?.documentID
                        dictUser.firstName = data["firstName"] as? String ?? ""
                        dictUser.lastName = data["lastName"] as? String ?? ""
                        dictUser.email = data["email"] as? String ?? ""
                        
                        self?.mainFriendsList.append(dictUser)
                    }
                }
            }
            
            group.notify(queue: .main) {
                
                self.searchData()
                self.hideSpinner()
            }
        }
    }
    
    fileprivate func getOrCreateChat(between user1: String, and user2: String, completion: @escaping (String) -> Void) {
        
        if !isConnectedToInternet() { return }
        
        self.showSpinner()
        
        let db = Firestore.firestore()
        let sortedIds = [user1, user2].sorted()
        let chatId = "\(sortedIds[0])_\(sortedIds[1])"
        
        let chatRef = db.collection("chats").document(chatId)
        
        chatRef.getDocument { snapshot, error in
            
            if let snapshot = snapshot, snapshot.exists {
                
                completion(chatId)
                
            } else {
                
                chatRef.setData([
                    "members": sortedIds,
                    "lastMessage": "",
                    "lastTimestamp": FieldValue.serverTimestamp()
                ]) { error in
                    completion(chatId)
                }
            }
            
            self.hideSpinner()
        }
    }
}



// MARK: -
extension HomeVC: UserListDelegate {
    
    func reloadMyFriendList() {
        self.fetchFriends()
    }
}


// MARK: - Button Touch & Action
extension HomeVC {
    
    @objc fileprivate func addFriendBtnTouch(_ sender: UIButton) {
        
        self.resignAllTextFields()
        
        self.fetchUsers()
    }
    
    @objc fileprivate func logoutBtnTouch(_ sender: UIButton) {
        
        self.resignAllTextFields()
        
        self.showSpinner()
        
        do {
            
            try Auth.auth().signOut()
            self.hideSpinner()
            setRootSignInVC()
            
        } catch {
            
            toastMessage(messageStr: "Error signing out: \(error.localizedDescription)")
            self.hideSpinner()
        }
    }
    
    @IBAction func searchCancelBtnTouch(_ sender: UIButton) {
        
        self.searchTextField.text = ""
        self.updateSearchContainerUI()
        
        self.tableView.backgroundView = nil
        
        self.searchedFriendsList.removeAll()
        self.searchedFriendsList = self.mainFriendsList
        
        self.tableView.reloadData()
        self.tableView.contentOffset = .zero
    }
}


// MARK: -
// MARK: - UITableView DataSource
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 {
            return self.searchedFriendsList.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 && indexPath.row < self.searchedFriendsList.count {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "HomeUserListCell") as? HomeUserListCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("HomeUserListCell", owner: self, options: nil)
                cell = nib![0] as? HomeUserListCell
            }
            
            cell?.configureCell(user: self.searchedFriendsList[indexPath.row])
            
            return cell!
            
        } else {
            return getTableCell()
        }
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 && indexPath.row < self.searchedFriendsList.count {
            
            if let otherUserId = self.searchedFriendsList[indexPath.row].uid, !otherUserId.isEmpty {
                
                self.getOrCreateChat(between: getDefaultUserId(), and: otherUserId) { [weak self] chatId in
                    
                    guard let self = self else { return }
                    
                    if !chatId.isEmpty {
                        
                        let chatVC = getStoryBoard(identifier: "ChatVC", storyBoardName: Constants.Storyboard.Main) as! ChatVC
                        chatVC.otherUser = self.searchedFriendsList[indexPath.row]
                        chatVC.chatId = chatId
                        self.navigationController?.pushViewController(chatVC, animated: true)
                        
                    } else {
                        toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
                    }
                }
            }
        }
    }
}


// MARK: - TextField Delegate
extension HomeVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        
        return true
    }
    
    @objc fileprivate func textFieldDidChange() {
        
        self.updateSearchContainerUI()
        self.searchData()
    }
}
