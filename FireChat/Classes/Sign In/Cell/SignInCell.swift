//
//  SignInCell.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import UIKit

class SignInCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var fNameTF: FloatingLabelTextField!
    @IBOutlet weak var lNameTF: FloatingLabelTextField!
    @IBOutlet weak var emailIdTF: FloatingLabelTextField!
    @IBOutlet weak var passwordTF: FloatingLabelTextField!
    
    
    // MARK: - Cell init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .getClearColour()
        self.selectionStyle = .none
        
        // Container
        self.container.backgroundColor = .getClearColour()
        
        // StackView
        self.stackView.backgroundColor = .getClearColour()
        self.stackView.axis = .vertical
        self.stackView.alignment = .fill
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 30
        
        // First Name TextField
        self.fNameTF.autocapitalizationType = .words
        self.fNameTF.keyboardType = .asciiCapable
        self.fNameTF.updateProperty(placeholderText: "Enter first name", floatingLabelText: "First Name")
        self.fNameTF.text = ""
        
        // Last Name TextField
        self.lNameTF.autocapitalizationType = .words
        self.lNameTF.keyboardType = .asciiCapable
        self.lNameTF.updateProperty(placeholderText: "Enter last name", floatingLabelText: "Last Name")
        self.lNameTF.text = ""
        
        // Email Id TextField
        self.emailIdTF.autocapitalizationType = .none
        self.emailIdTF.keyboardType = .emailAddress
        self.emailIdTF.updateProperty(placeholderText: "Enter email id", floatingLabelText: "Email Id")
        self.emailIdTF.text = ""
        
        // Password TextField
        self.emailIdTF.autocapitalizationType = .none
        self.passwordTF.keyboardType = .emailAddress
        self.passwordTF.updateProperty(placeholderText: "Enter password", floatingLabelText: "Password")
        self.passwordTF.isSecureTextEntry = true
        self.passwordTF.text = ""
    }
    
    
    // MARK: - Cell Configuration
    func configureCell(fName: String = "", lName: String = "", emailId: String, password: String, isSignUp: Bool = false) {
        
        // First Name & Last Name
        self.fNameTF.text = ""
        self.fNameTF.isHidden = true
        
        self.lNameTF.text = ""
        self.lNameTF.isHidden = true
        if isSignUp {
            
            self.fNameTF.text = fName
            self.fNameTF.updateTextFieldUI()
            self.fNameTF.isHidden = false
            
            self.lNameTF.text = lName
            self.lNameTF.updateTextFieldUI()
            self.lNameTF.isHidden = false
        }
        
        // Email Id TextField
        self.emailIdTF.text = emailId
        self.emailIdTF.updateTextFieldUI()
        
        // Password TextField
        self.passwordTF.text = password
        self.passwordTF.updateTextFieldUI()
    }
}
