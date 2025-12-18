//
//  HomeUserListCell.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 10/10/25.
//

import UIKit

class HomeUserListCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var userInitialLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var disclosureIcon: UIImageView!
    
    
    // MARK: - Cell init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .getClearColour()
        self.selectionStyle = .none
        
        // Container
        self.container.backgroundColor = .getCardBgColor()
        self.container.addRadiusWithBorder(radius: 10)
        
        // User Initial Label
        self.userInitialLabel.backgroundColor = .getButtonBgColor()
        self.userInitialLabel.textColor = .getButtonTextColor()
        self.userInitialLabel.font = .systemFont(ofSize: 10, weight: .medium)
        self.userInitialLabel.textAlignment = .center
        self.userInitialLabel.numberOfLines = 1
        self.userInitialLabel.lineBreakMode = .byTruncatingTail
        self.userInitialLabel.layer.cornerRadius = self.userInitialLabel.bounds.width / 2
        self.userInitialLabel.clipsToBounds = true
        self.userInitialLabel.text = ""
        
        // Username Label
        self.usernameLabel.backgroundColor = .getClearColour()
        self.usernameLabel.textColor = .getTextColor()
        self.usernameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        self.usernameLabel.textAlignment = .left
        self.usernameLabel.numberOfLines = 0
        self.usernameLabel.lineBreakMode = .byWordWrapping
        self.usernameLabel.text = ""
        
        // Disclosure Icon
        self.disclosureIcon.backgroundColor = .getClearColour()
        self.disclosureIcon.image = UIImage(named: "DisclosureWhiteIcon")?.withRenderingMode(.alwaysTemplate)
        self.disclosureIcon.contentMode = .scaleAspectFit
        self.disclosureIcon.tintColor = .getTextColor()
    }
    
    
    // MARK: - Cell Configuration
    func configureCell(user: UserDataModel?) {
        
        // User Initial & Username Label
        self.userInitialLabel.text = ""
        self.usernameLabel.text = ""
        
        var usernameStr = ""
        if let firstName = user?.firstName, !firstName.isEmpty {
            usernameStr = firstName
        }
        
        if let lastName = user?.lastName, !lastName.isEmpty {
            usernameStr = !usernameStr.isEmpty ? (usernameStr + " " + lastName) : lastName
        }
        
        self.userInitialLabel.text = getInitials(from: usernameStr)
        self.usernameLabel.text = usernameStr
    }
}
