//
//  SignInVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import UIKit
import FirebaseAuth

class SignInVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var orView: UIView!
    @IBOutlet weak var orLeftEmptySeparator: UIView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var orRightEmptySeparator: UIView!
    
    @IBOutlet weak var createAccountBtn: UIButton!
    
    @IBOutlet weak var createAccountBtnBottom: NSLayoutConstraint!
    
    
    // MARK: - Properties
    fileprivate var refEmailIdTF: FloatingLabelTextField?
    fileprivate var refPasswordTF: FloatingLabelTextField?
    
    fileprivate lazy var emailId = ""
    fileprivate lazy var password = ""
    
    fileprivate lazy var bottomConstant: CGFloat = 30
    
    fileprivate let spinner = HVDOverlayExtended.spinnerOverlay()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Sign In"
        
        self.setControlsProperty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        NC.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NC.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NC.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NC.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func setControlsProperty() {
        
        // View Background
        self.view.backgroundColor = .getBgColor()
        
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
        
        // Sign In Buttton
        self.signInBtn.backgroundColor = .getButtonBgColor()
        self.signInBtn.titleLabel?.backgroundColor = .getButtonBgColor()
        self.signInBtn.setTitleColor(.getButtonTextColor(), for: .normal)
        self.signInBtn.solidFilledBtn(radius: 10)
        self.signInBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        self.signInBtn.setTitle("Sign In", for: .normal)
        self.signInBtn.startAnimatingPressActions()
        
        // Or View
        self.orView.backgroundColor = .getClearColour()
        self.orLeftEmptySeparator.backgroundColor = .getHSeparatorColor()
        self.orRightEmptySeparator.backgroundColor = .getHSeparatorColor()
        
        self.orLabel.backgroundColor = .getClearColour()
        self.orLabel.textColor = .getTextColor(alpha: 0.4)
        self.orLabel.font = .systemFont(ofSize: 12, weight: .regular)
        self.orLabel.textAlignment = .center
        self.orLabel.text = "OR"
        
        // Create Account Button
        self.createAccountBtn.backgroundColor = .getClearColour()
        self.createAccountBtn.titleLabel?.backgroundColor = .getClearColour()
        self.createAccountBtn.setAttributedTitle(multiUnderLineAttributedString(strings: ["No account? ", "Create a new account"], fonts: [.systemFont(ofSize: 16, weight: .semibold), .systemFont(ofSize: 16, weight: .semibold)], colors: [.getTextColor(alpha: 0.7), .getTextColor()], alignments: [.center, .center], isUnderline: [false, true]), for: .normal)
        self.createAccountBtn.titleLabel?.lineBreakMode = .byClipping
        self.createAccountBtn.startAnimatingPressActions()
        
        self.createAccountBtnBottom.constant = UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : self.bottomConstant
    }
}


// MARK: - Call Back
extension SignInVC {
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if SCREENHEIGHT <= 667 {
                return
            }
            
            self.createAccountBtnBottom.constant = keyboardSize.height - getBottomSafeAreaHeight() + self.bottomConstant + (UIDevice.current.hasNotch ? 30 : 0)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        if SCREENHEIGHT <= 667 {
            return
        }
        
        self.createAccountBtnBottom.constant = UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : self.bottomConstant
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func checkValidation() -> Bool {
        
        var isValid = true
        
        if self.emailId.isEmpty {
            
            isValid = false
            toastMessage(messageStr: Constants.Generic.EmailEmpty)
            
        } else if !ValidationUtils.isValidEmail(self.emailId) {
            
            isValid = false
            toastMessage(messageStr: Constants.Generic.EmailInvalid)
            
        } else if self.password.isEmpty {
            
            isValid = false
            toastMessage(messageStr: Constants.Generic.PasswordEmpty)
            
        } else if !ValidationUtils.isValidPassword(self.password) {
            
            isValid = false
            toastMessage(messageStr: Constants.Generic.PasswordInvalid)
        }
        
        return isValid
    }
    
    fileprivate func showSpinner() {
        self.spinner?.show(on: APPDELEOBJ.window)
    }
    
    fileprivate func hideSpinner() {
        self.spinner?.dismiss()
    }
    
    fileprivate func resignAllTextFields() {
        
        self.refEmailIdTF?.resignFirstResponder()
        self.refPasswordTF?.resignFirstResponder()
    }
}


// MARK: - Button Touch & Action
extension SignInVC {
    
    @IBAction func signInBtnTouch(_ sender: Any) {
        
        self.resignAllTextFields()
        
        self.emailId = self.emailId.trimmingCharacters(in: .whitespaces)
        
        if checkValidation(),
           isConnectedToInternet() {
            
            self.showSpinner()
            
            Auth.auth().signIn(withEmail: self.emailId, password: self.password) { authResult, error in
                
                if let error = error {
                    toastMessage(messageStr: "Sign-up failed: \(error.localizedDescription)")
                } else {
                    
                    addAnalyticsEvent(eventName: "SignIn", params: ["emailId": self.emailId])
                    setRootHomeVC()
                }
                
                self.hideSpinner()
            }
        }
    }
    
    @IBAction func signUpBtnTouch(_ sender: Any) {
        
        self.resignAllTextFields()
        
        let signUpVC = getStoryBoard(identifier: "SignUpVC", storyBoardName: Constants.Storyboard.Main) as! SignUpVC
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
}


// MARK: -
// MARK: - UITableView DataSource
extension SignInVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "SignInCell") as? SignInCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("SignInCell", owner: self, options: nil)
                cell = nib![0] as? SignInCell
            }
            
            cell?.emailIdTF.delegate = self
            cell?.passwordTF.delegate = self
            
            self.refEmailIdTF = cell?.emailIdTF
            self.refPasswordTF = cell?.passwordTF
            
            cell?.configureCell(emailId: self.emailId, password: self.password)
            
            self.refEmailIdTF?.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            self.refPasswordTF?.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            
            return cell!
            
        } else {
            return getTableCell()
        }
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.resignAllTextFields()
    }
}


// MARK: - UITextField Delegate
extension SignInVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.refEmailIdTF || textField == self.refPasswordTF {
            
            if range.location == 0 && string == " " {
                return false
            }
            
            if string == " " || string == "\n" {
                return false
            }
        }
        
        return true
    }
    
    @objc fileprivate func textFieldDidChange(_ sender: UITextField) {
        
        if sender == self.refEmailIdTF {
            
            // Email Id TextField
            if let email = self.refEmailIdTF?.text, !email.isEmpty {
                self.emailId = email
            } else {
                self.emailId = ""
            }
            
        } else if sender == self.refPasswordTF {
            
            // Password TextField
            if let pass = self.refPasswordTF?.text, !pass.isEmpty {
                self.password = pass
            } else {
                self.password = ""
            }
        }
    }
}

