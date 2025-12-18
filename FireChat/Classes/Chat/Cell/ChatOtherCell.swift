//
//  ChatOtherCell.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 13/10/25.
//

import UIKit

class ChatOtherCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var userInitialLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var msgAttachBgView: UIView!
    @IBOutlet weak var msgAttachStackView: UIStackView!
    
    @IBOutlet weak var attachView: UIView!
    @IBOutlet weak var attachImage: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var mediaBtn: ChatMessageButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    
    // MARK: - Cell init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .getClearColour()
        self.selectionStyle = .none
        
        // Container
        self.container.backgroundColor = .getClearColour()
        
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
        
        // StackView
        self.stackView.backgroundColor = .getClearColour()
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.distribution = .fill
        self.stackView.spacing = 5
        
        // Message Attach Background View
        self.msgAttachBgView.backgroundColor = .getChatOtherBgColor()
        self.msgAttachBgView.addRadiusWithBorder(radius: 10)
        self.msgAttachBgView.clipsToBounds = true
        
        // Message Attach StackView
        self.msgAttachStackView.backgroundColor = .getClearColour()
        self.msgAttachStackView.axis = .vertical
        self.msgAttachStackView.alignment = .leading
        self.msgAttachStackView.distribution = .fill
        self.msgAttachStackView.spacing = 5
        
        // Attach View
        self.attachView.backgroundColor = .getClearColour()
        
        // Attach Image
        self.attachImage.backgroundColor = .getClearColour()
        self.attachImage.contentMode = .scaleAspectFill
        self.attachImage.layer.cornerRadius = 10
        self.attachImage.clipsToBounds = true
        
        // Play Icon
        self.playIcon.backgroundColor = .getBgColor()
        self.playIcon.image = UIImage(named: "PlayIcon")?.withRenderingMode(.alwaysTemplate)
        self.playIcon.tintColor = .getTextColor()
        self.playIcon.contentMode = .center
        self.playIcon.layer.cornerRadius = self.playIcon.bounds.width / 2
        self.playIcon.clipsToBounds = true
        
        // Media Button
        self.mediaBtn.backgroundColor = .getClearColour()
        
        // Message Label
        self.messageLabel.backgroundColor = .getClearColour()
        self.messageLabel.textColor = .getTextColor()
        self.messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        self.messageLabel.textAlignment = .left
        self.messageLabel.numberOfLines = 0
        self.messageLabel.lineBreakMode = .byWordWrapping
        self.messageLabel.text = ""
        
        // Date Time Label
        self.dateTimeLabel.backgroundColor = .getClearColour()
        self.dateTimeLabel.textColor = .getTextColor(alpha: 0.8)
        self.dateTimeLabel.font = .systemFont(ofSize: 10, weight: .regular)
        self.dateTimeLabel.textAlignment = .left
        self.dateTimeLabel.numberOfLines = 1
        self.dateTimeLabel.lineBreakMode = .byTruncatingTail
        self.dateTimeLabel.text = ""
    }
    
    
    // MARK: - Cell Configuration
    func configureCell(messageData: ChatMessageModel?, userName: String) {
        
        // Media Button
        self.mediaBtn.chat = messageData
        
        // User Initial Label
        self.userInitialLabel.text = "OU"
        if !userName.isEmpty {
            self.userInitialLabel.text = getInitials(from: userName)
        }
        
        // Attach Image
        var isAttachment = false
        self.attachImage.image = nil
        self.attachImage.contentMode = .scaleAspectFill
        self.attachImage.isHidden = true
        
        self.playIcon.isHidden = true
        
        self.attachView.isHidden = true
        
        if let mediatype = messageData?.mediaType, mediatype == MediaType.DOCUMENT,
           let mediaurl = messageData?.mediaURL, !mediaurl.isEmpty {
            
            isAttachment = true
            
            self.attachImage.image = UIImage(named: "ImageFileIcon")
            self.attachImage.contentMode = .center
            
        } else if let mediatype = messageData?.mediaType, mediatype == MediaType.IMAGE,
                  let mediaurl = messageData?.mediaURL, !mediaurl.isEmpty {
            
            isAttachment = true
            
            self.attachImage.sd_setImage(with: URL(string: mediaurl))
            
        } else if let mediatype = messageData?.mediaType, mediatype == MediaType.VIDEO,
                  let thumbnailurl = messageData?.thumbnailURL, !thumbnailurl.isEmpty {
            
            isAttachment = true
            
            self.attachImage.sd_setImage(with: URL(string: thumbnailurl))
            self.playIcon.isHidden = false
        }
        
        if isAttachment {
            self.attachImage.isHidden = false
            self.attachView.isHidden = false
        }
        
        // Message Label
        self.messageLabel.text = ""
        self.messageLabel.isHidden = true
        if let msg = messageData?.message, !msg.isEmpty {
            self.messageLabel.text = msg
            self.messageLabel.isHidden = false
        }
        
        // Message Attach Background View
        self.msgAttachBgView.isHidden = false
        if !isAttachment && self.messageLabel.isHidden {
            self.msgAttachBgView.isHidden = true
        }
        
        // Date Time Label
        self.dateTimeLabel.text = ""
        if let dateTimestamp = messageData?.timestamp {
            self.dateTimeLabel.text = dateFormatter(date: dateTimestamp, dateformat: Constants.DateTimeFormatter.date2)
        }
    }
}
