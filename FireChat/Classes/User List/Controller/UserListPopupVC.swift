//
//  UserListPopupVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 04/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

protocol UserListDelegate: AnyObject {
    func reloadMyFriendList()
}

class UserListPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet var topContainer: UIView!
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var topSeparator: UIView!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchCancelBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noUserListLabel: UILabel!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    // MARK: - Properties
    lazy var mainUsersList = [UserDataModel]()
    fileprivate lazy var searchedUsersList = [UserDataModel]()
    fileprivate let db = Firestore.firestore()
    
    var userListDelegate: UserListDelegate?
    
    fileprivate let spinner = HVDOverlayExtended.spinnerOverlay()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setControlsProperty()
        
        self.searchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.updateSearchContainerUI()
        }
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .getClearColour()
        self.view.isOpaque = false
        
        // Overlay Button
        self.overlayButton.backgroundColor = .getButtonBgColor()
        self.overlayButton.alpha = 0.0
        
        // Container
        self.container.backgroundColor = .getBgColor()
        self.container.addRadiusWithBorder(radius: 10)
        
        // Top Container
        self.topContainer.backgroundColor = .getClearColour()
        
        // Close Button
        self.closeBtn.backgroundColor = .getClearColour()
        self.closeBtn.setImage(UIImage(named: "CloseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeBtn.tintColor = .getButtonBgColor()
        self.closeBtn.showsTouchWhenHighlighted = false
        self.closeBtn.adjustsImageWhenHighlighted = false
        self.closeBtn.adjustsImageWhenDisabled = false
        
        // Header Label
        self.headerLabel.backgroundColor = .getClearColour()
        self.headerLabel.textColor = .getTextColor()
        self.headerLabel.font = .systemFont(ofSize: 18, weight: .bold)
        self.headerLabel.numberOfLines = 1
        self.headerLabel.lineBreakMode = .byTruncatingTail
        self.headerLabel.textAlignment = .center
        self.headerLabel.text = "Users"
        
        // Top Separator
        self.topSeparator.backgroundColor = .getHSeparatorColor()
        
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
        
        self.tableView.tag = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.tableFooterView = UIView().addTableFooter(height: UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : 20)
        self.tableView.tableFooterView?.backgroundColor = .getClearColour()
        
        // No User List Label
        self.noUserListLabel.backgroundColor = .getClearColour()
        self.noUserListLabel.textColor = .getTextColor()
        self.noUserListLabel.font = .systemFont(ofSize: 12, weight: .medium)
        self.noUserListLabel.textAlignment = .center
        self.noUserListLabel.numberOfLines = 1
        self.noUserListLabel.lineBreakMode = .byTruncatingTail
        self.noUserListLabel.text = Constants.Generic.NoUserFound
        self.noUserListLabel.isHidden = true
        
        self.container.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrageDown(_:))))
    }
}


//MARK: - Call Back
extension UserListPopupVC {
    
    fileprivate func showTransition() {
        
        UIView.animate(withDuration: 0.2) {
            self.overlayButton.alpha = 0.6
            self.overlayButton.isUserInteractionEnabled = true
        }
        
        let h = self.container.bounds.height
        
        self.container.frame = CGRect(x: 0, y: SCREENHEIGHT, width: SCREENWIDTH, height: self.container.bounds.height)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.container.frame = CGRect(x: 0, y: SCREENHEIGHT - h, width: SCREENWIDTH, height: h)
        })
    }
    
    fileprivate func hideTransition(isReloadPage: Bool = false, message: String = "") {
        
        let y = self.container.bounds.height
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.container.frame = CGRect(x: 0, y: SCREENHEIGHT, width: SCREENWIDTH, height: y)
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func onDrageDown(_ sender: UIPanGestureRecognizer) {
        
        let translationY = sender.translation(in: sender.view!).y
        
        switch sender.state {
            
        case .began:
            break
            
        case .changed:
            // print("Y = \(translationY)")
            
            var transY: CGFloat = 0
            if translationY < 0 {
                transY = 0
            } else if translationY > 0 {
                transY = translationY
            }
            
            self.container.transform = CGAffineTransform(translationX: 0, y: transY)
            
        case .ended, .cancelled:
            
            if translationY > self.container.frame.height / 2 {
                self.hideTransition()
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.container.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    fileprivate func showSpinner() {
        self.spinner?.show(on: APPDELEOBJ.window)
    }
    
    fileprivate func hideSpinner() {
        self.spinner?.dismiss()
    }
    
    fileprivate func searchData() {
        
        self.tableView.backgroundView = nil
        
        self.searchedUsersList = self.mainUsersList
        
        if let text = self.searchTextField.text, !text.isEmpty {
            
            self.searchedUsersList = self.mainUsersList.filter({
                $0.firstName?.range(of: text, options: .caseInsensitive) != nil ||
                $0.lastName?.range(of: text, options: .caseInsensitive) != nil })
        }
        
        if self.searchedUsersList.isEmpty {
            
            self.noUserListLabel.isHidden = false
            self.tableView.isHidden = true
            
        } else {
            
            self.tableView.isHidden = false
            self.noUserListLabel.isHidden = true
        }
        
        self.tableView.reloadData()
        self.tableView.contentOffset = .zero
        
        self.tableViewHeight.constant = CGFloat.greatestFiniteMagnitude
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            let maxHeight = SCREENHEIGHT - 67 - 50 - self.searchContainer.frame.height
            
            if self.tableView.contentSize.height > maxHeight {
                self.tableView.isScrollEnabled = true
            } else {
                self.tableView.isScrollEnabled = false
            }
            
            self.tableViewHeight.constant = maxHeight
            
            self.container.layoutIfNeeded()
            
            self.container.frame = CGRect(x: 0, y: SCREENHEIGHT, width: SCREENWIDTH, height: self.container.bounds.height)
            self.view.isHidden = false
            
            self.showTransition()
        }
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
extension UserListPopupVC {
    
    fileprivate func addFriend(friendId: String) {
        
        if !isConnectedToInternet() { return }
        
        self.showSpinner()
        
        let currentUserId = getDefaultUserId()
        
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(currentUserId)
        let friendUserRef = db.collection("users").document(friendId)
        
        let timestamp = Date().timeIntervalSince1970
        
        currentUserRef.collection("friends").document(friendId).getDocument { snapshot, error in
            
            if let error = error {
                
                toastMessage(messageStr: "Error checking friend: \(error.localizedDescription)")
                self.hideSpinner()
                
                return
            }
            
            // ✅ If document already exists, do nothing
            if snapshot?.exists == true {
                
                toastMessage(messageStr: "Already friends")
                self.hideSpinner()
                
                return
            }
            
            // Otherwise, add both sides of the friendship
            let batch = db.batch()
            
            batch.setData(["connectedAt": timestamp],
                          forDocument: currentUserRef.collection("friends").document(friendId))
            batch.setData(["connectedAt": timestamp],
                          forDocument: friendUserRef.collection("friends").document(currentUserId))
            
            batch.commit { error in
                
                if let error = error {
                    toastMessage(messageStr: "Error adding friend: \(error.localizedDescription)")
                } else {
                    
                    toastMessage(messageStr: "Friend added successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        
                        if let delegate = self.userListDelegate {
                            delegate.reloadMyFriendList()
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                self.hideSpinner()
            }
        }
    }
}


// MARK: - Button Touch & Action
extension UserListPopupVC {
    
    @IBAction func overlayBtnAction(_ sender: UIButton) {
        self.hideTransition()
    }
    
    @IBAction func closeTouch(_ sender: UIButton) {
        self.hideTransition()
    }
    
    @IBAction func searchCancelBtnTouch(_ sender: UIButton) {
        
        self.searchTextField.text = ""
        self.updateSearchContainerUI()
        
        self.tableView.backgroundView = nil
        
        self.searchedUsersList.removeAll()
        self.searchedUsersList = self.mainUsersList
        
        self.tableView.reloadData()
        self.tableView.contentOffset = .zero
    }
}


// MARK: -
// MARK: - UITableView DataSource
extension UserListPopupVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 {
            return self.searchedUsersList.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 && indexPath.row < self.searchedUsersList.count {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "HomeUserListCell") as? HomeUserListCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("HomeUserListCell", owner: self, options: nil)
                cell = nib![0] as? HomeUserListCell
            }
            
            cell?.configureCell(user: self.searchedUsersList[indexPath.row])
            
            return cell!
            
        } else {
            return getTableCell()
        }
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 && indexPath.row < self.searchedUsersList.count {
            
            if let otherUserId = self.searchedUsersList[indexPath.row].uid, !otherUserId.isEmpty {
                self.addFriend(friendId: otherUserId)
            }
        }
    }
}


// MARK: - TextField Delegate
extension UserListPopupVC: UITextFieldDelegate {
    
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

