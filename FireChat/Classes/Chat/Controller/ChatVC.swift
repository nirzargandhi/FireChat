//
//  ChatVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 13/10/25.
//

import UIKit
import AVKit
import FirebaseFirestoreInternal
import FirebaseStorage
import ZLPhotoBrowser
import SKPhotoBrowser
import MobileCoreServices
import UniformTypeIdentifiers

struct MediaType {
    
    static let TEXT         = "text"
    static let DOCUMENT     = "document"
    static let IMAGE        = "image"
    static let AUDIO        = "audio"
    static let VIDEO        = "video"
    static let THUMBNAIL    = "thumbnail"
}

class ChatVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendMessageContainer: UIView!
    
    @IBOutlet weak var sendMessageTextContainer: UIView!
    @IBOutlet weak var sendMessageTextView: UITextView!
    @IBOutlet weak var sendMessageTextPlaceholderLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var attachmentBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var sendMessageBtn: UIButton!
    
    @IBOutlet weak var sendMessageTextContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var sendMessageContainerBottom: NSLayoutConstraint!
    
    
    // MARK: - Properties
    fileprivate lazy var groupedMessages = [GroupedMessagesModel]()
    
    lazy var otherUser = UserDataModel()
    lazy var chatId = ""
    
    fileprivate lazy var otherUsername = ""
    fileprivate lazy var messageText = ""
    fileprivate let defaultTextViewHeight: CGFloat = 47
    fileprivate let maxChars = 1000
    
    fileprivate let maxAllowedFilesCount = 1
    
    fileprivate let spinner = HVDOverlayExtended.spinnerOverlay()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setControlsProperty()
        self.addLeftBarButton(isShow: true)
        
        self.getChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        APPDELEOBJ.isRestrictRotation = true
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.updateTextViewUI()
        }
    }
    
    fileprivate func setControlsProperty() {
        
        // Navigation Title
        if let firstName = self.otherUser.firstName, !firstName.isEmpty {
            otherUsername = firstName
        }
        if let lastName = self.otherUser.lastName, !lastName.isEmpty {
            otherUsername = !otherUsername.isEmpty ? (otherUsername + " " + lastName) : lastName
        }
        self.title = !otherUsername.isEmpty ? otherUsername : "Chat"
        
        
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
        self.tableView.isHidden = true
        
        self.tableView.tableFooterView = UIView().addTableFooter(height: UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : 20)
        self.tableView.tableFooterView?.backgroundColor = .getClearColour()
        
        // Send Message Container
        self.sendMessageContainer.backgroundColor = .getClearColour()
        
        // Text Container
        self.sendMessageTextContainer.backgroundColor = .getClearColour()
        self.sendMessageTextContainer.addRadiusWithBorder(radius: 10, border: 1)
        self.sendMessageTextContainer.layer.borderColor = UIColor.getUnSelectedBorderColor().cgColor
        
        // Text View
        self.sendMessageTextView.backgroundColor = .getClearColour()
        self.sendMessageTextView.textColor = .getTextColor()
        self.sendMessageTextView.tintColor = .getTextColor()
        self.sendMessageTextView.font = .systemFont(ofSize: 15, weight: .regular)
        self.sendMessageTextView.keyboardAppearance = .default
        self.sendMessageTextView.keyboardType = .asciiCapable
        self.sendMessageTextView.autocorrectionType = .no
        self.sendMessageTextView.spellCheckingType = .no
        self.sendMessageTextView.textAlignment = .left
        self.sendMessageTextView.isScrollEnabled = false
        self.sendMessageTextView.delegate = self
        self.sendMessageTextView.text = ""
        
        // Text Placeholder Label
        self.sendMessageTextPlaceholderLabel.backgroundColor = .getClearColour()
        self.sendMessageTextPlaceholderLabel.textColor = .getTextColor(alpha: 0.5)
        self.sendMessageTextPlaceholderLabel.font = .systemFont(ofSize: 15, weight: .regular)
        self.sendMessageTextPlaceholderLabel.textAlignment = .left
        self.sendMessageTextPlaceholderLabel.text = "Enter message"
        
        // StackView
        self.stackView.backgroundColor = .getClearColour()
        self.stackView.axis = .horizontal
        self.stackView.alignment = .fill
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 10
        
        // Attachment Button
        self.attachmentBtn.backgroundColor = .getButtonBgColor()
        self.attachmentBtn.layer.cornerRadius = self.attachmentBtn.bounds.width / 2
        self.attachmentBtn.setImage(UIImage(named: "AttachmentIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.attachmentBtn.tintColor = .getButtonTextColor()
        self.attachmentBtn.showsTouchWhenHighlighted = false
        self.attachmentBtn.adjustsImageWhenHighlighted = false
        self.attachmentBtn.adjustsImageWhenDisabled = false
        self.attachmentBtn.startAnimatingPressActions()
        
        // Camera Button
        self.cameraBtn.backgroundColor = .getButtonBgColor()
        self.cameraBtn.layer.cornerRadius = self.cameraBtn.bounds.width / 2
        self.cameraBtn.setImage(UIImage(named: "CameraIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.cameraBtn.tintColor = .getButtonTextColor()
        self.cameraBtn.showsTouchWhenHighlighted = false
        self.cameraBtn.adjustsImageWhenHighlighted = false
        self.cameraBtn.adjustsImageWhenDisabled = false
        self.cameraBtn.startAnimatingPressActions()
        
        // Send Message Button
        self.sendMessageBtn.backgroundColor = .getButtonBgColor()
        self.sendMessageBtn.layer.cornerRadius = self.sendMessageBtn.bounds.width / 2
        self.sendMessageBtn.setImage(UIImage(named: "SendMessageIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendMessageBtn.tintColor = .getButtonTextColor()
        self.sendMessageBtn.showsTouchWhenHighlighted = false
        self.sendMessageBtn.adjustsImageWhenHighlighted = false
        self.sendMessageBtn.adjustsImageWhenDisabled = false
        self.sendMessageBtn.startAnimatingPressActions()
        
        self.sendMessageContainerBottom.constant = UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : 20
    }
}


// MARK: - Call Back
extension ChatVC {
    
    fileprivate func showSpinner() {
        self.spinner?.show(on: APPDELEOBJ.window)
    }
    
    fileprivate func hideSpinner() {
        self.spinner?.dismiss()
    }
    
    fileprivate func getChats() {
        
        self.showSpinner()
        
        self.groupedMessages.removeAll()
        self.tableView.reloadData()
        
        self.tableView.isHidden = true
        
        self.fetchUserChats(userId: getDefaultUserId()) { [weak self] messages in
            
            guard let self = self else { return }
            
            var images = [String]()
            
            for msg in messages {
                
                if msg.mediaType == MediaType.IMAGE,
                   let imageUrl = msg.mediaURL, !imageUrl.isEmpty {
                    
                    images.append(imageUrl)
                    
                } else if msg.mediaType == MediaType.THUMBNAIL,
                          let thumbnailurl = msg.thumbnailURL, !thumbnailurl.isEmpty {
                    
                    images.append(thumbnailurl)
                }
            }
            
            if !images.isEmpty {
                preloadImages(images: images)
            }
            
            self.groupedMessages = self.groupMessagesByDate(messages: messages)
            
            if !self.groupedMessages.isEmpty {
                self.tableView.isHidden = false
            }
            
            self.tableView.reloadData()
            self.scrollToBottom()
            
            self.hideSpinner()
        }
    }
    
    fileprivate func groupMessagesByDate(messages: [ChatMessageModel]) -> [GroupedMessagesModel] {
        
        let calendar = Calendar.current
        let groupedDict = Dictionary(grouping: messages) { message -> Date in
            return calendar.startOfDay(for: message.timestamp ?? Date())
        }
        
        let sortedGroups = groupedDict.sorted { $0.key < $1.key }
        return sortedGroups.map { GroupedMessagesModel(date: $0.key, messages: $0.value.sorted { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) }
    }
    
    fileprivate func scrollToBottom() {
        
        let intSection : Int = self.groupedMessages.count - 1
        
        guard intSection > -1 else {
            return
        }
        
        let intRow = (self.groupedMessages[intSection].messages.count) - 1
        
        guard intRow > -1 else {
            return
        }
        
        let indexPath = IndexPath(row: intRow, section: intSection)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    fileprivate func fetchFiles() {
        
        var documentPickerController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String],in: .open)
        
        if #available(iOS 14.0, *) {
            documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        }
        
        documentPickerController.allowsMultipleSelection = true
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    fileprivate func openPickerImage() {
        
        ZLPhotoConfiguration.default()
            .canSelectAsset { _ in true }
            .maxSelectCount(1)
            .allowSelectOriginal(false)
            .allowMixSelect(false)
            .allowTakePhotoInLibrary(true)
            .allowSelectImage(true)
            .allowEditImage(true)
            .allowSelectVideo(true)
            .noAuthorityCallback({ type in
                switch type {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            })
            .cameraConfiguration.allowRecordVideo(true)
        
        ZLPhotoUIConfiguration.default()
            .navCancelButtonStyle(.text)
            .columnCount(3)
            .showIndexOnSelectBtn(true)
            .cellCornerRadio(5.0)
            .showStatusBarInPreviewInterface(true)
            .sortAscending(false)
            .selectedBorderColor(.getSelectedBorderColor())
            .indexLabelBgColor(.getBgColor())
            .bottomToolViewBgColor(.getBgColor())
            .bottomToolViewBtnNormalBgColor(.getButtonBgColor())
            .bottomToolViewBtnNormalTitleColor(.getButtonTextColor())
            .bottomToolViewBtnNormalBgColorOfPreviewVC(.getBgColor())
            .bottomToolViewBtnNormalTitleColorOfPreviewVC(.getButtonTextColor())
            .bottomToolViewDoneBtnNormalTitleColorOfPreviewVC(.getButtonBgColor())
            .bottomToolViewDoneBtnNormalTitleColor(.getButtonTextColor())
        
        let picker = ZLPhotoPicker()
        picker.selectImageBlock = { [weak self] (results, _) in
            
            guard let self = self else { return }
            
            if !results.isEmpty {
                
                for result in results {
                    
                    if result.asset.mediaType == .video {
                        
                        getVideoData(from: result.asset) { videoData in
                            
                            if let videodata = videoData {
                                
                                let fileName = "video_\(UUID().uuidString).mp4"
                                self.startUploadingMedia(data: videodata, fileName: fileName, mediaType: MediaType.VIDEO, videoUrl: "")
                            }
                        }
                        
                        break
                        
                    } else if result.asset.mediaType == .image,
                              let imageData = results[0].image.jpegData(compressionQuality: 0.8) {
                        
                        let fileName = "image_\(UUID().uuidString).jpg"
                        self.startUploadingMedia(data: imageData, fileName: fileName, mediaType: MediaType.IMAGE, videoUrl: "")
                        
                        break
                    }
                }
                
            } else {
                toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
            }
        }
        
        picker.cancelBlock = {  print("cancel select")  }
        
        picker.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            print("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
            toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
        }
        
        picker.showPhotoLibrary(sender: self)
    }
    
    fileprivate func startUploadingMedia(data: Data, fileName: String, mediaType: String, videoUrl: String) {
        
        DispatchQueue.main.async {
            
            self.uploadMedia(data, fileName: fileName) { [weak self] url in
                
                guard let self = self else { return }
                
                guard let url = url else {
                    toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
                    return
                }
                
                if let otherUserId = self.otherUser.uid, !otherUserId.isEmpty {
                    
                    if mediaType == MediaType.VIDEO {
                        
                        generateThumbnailFromFirebase(urlString: url) { thumbnailUrl in
                            
                            if let imageData = thumbnailUrl?.jpegData(compressionQuality: 0.8) {
                                
                                let fileName = "thumbnail_\(UUID().uuidString).jpg"
                                self.startUploadingMedia(data: imageData, fileName: fileName, mediaType: MediaType.THUMBNAIL, videoUrl: url)
                            }
                        }
                        
                    } else if mediaType == MediaType.THUMBNAIL {
                        
                        self.sendMessage(from: getDefaultUserId(), to: otherUserId, mediaURL: videoUrl, thumbnailUrl: url, type: MediaType.VIDEO, text: self.messageText)
                        
                    } else {
                        
                        self.sendMessage(from: getDefaultUserId(), to: otherUserId, mediaURL: url, thumbnailUrl: "", type: mediaType, text: self.messageText)
                    }
                    
                } else {
                    toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
                }
            }
        }
    }
    
    fileprivate func openPhotoViewer(imageStrUrl: String) {
        
        var imgs = [SKPhoto]()
        let validurl = verifyUrl(urlString: imageStrUrl)
        
        guard validurl else {
            return
        }
        
        let photo = SKPhoto.photoWithImageURL(imageStrUrl)
        imgs.append(photo)
        
        if !imgs.isEmpty {
            
            APPDELEOBJ.isRestrictRotation = false
            
            // 2. create PhotoBrowser Instance, and present from self ViewController
            let browser = SKPhotoBrowser(photos: imgs)
            browser.initializePageIndex(0)
            browser.delegate = self
            present(browser, animated: true, completion: {})
        }
    }
    
    fileprivate func openVideoPlayer(videoStr: String) {
        
        APPDELEOBJ.isRestrictRotation = false
        
        guard let videoUrl = URL(string: videoStr) else {
            toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
            return
        }
        
        let playerViewController = AVPlayerViewController()
        playerViewController.delegate = self
        self.present(playerViewController, animated: true, completion: nil)
        
        var videoPlayer: AVPlayer!
        let avAsset = AVURLAsset(url: videoUrl, options: nil)
        
        let playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        playerViewController.player = videoPlayer
        videoPlayer.play()
    }
    
    fileprivate func updateTextViewUI() {
        
        if self.messageText.isEmpty {
            self.sendMessageTextContainer.layer.borderColor = UIColor.getUnSelectedBorderColor().cgColor
        } else {
            self.sendMessageTextContainer.layer.borderColor = UIColor.getSelectedBorderColor().cgColor
        }
    }
    
    fileprivate func resignAllTextView() {
        self.sendMessageTextView?.resignFirstResponder()
    }
}


// MARK: - Firebase Chat Method
extension ChatVC {
    
    fileprivate func fetchUserChats(userId: String, completion: @escaping ([ChatMessageModel]) -> Void) {
        
        if !isConnectedToInternet() { return }
        
        Firestore.firestore()
            .collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                
                let result = snapshot?.documents.compactMap { doc -> ChatMessageModel? in
                    try? doc.data(as: ChatMessageModel.self)
                } ?? []
                
                completion(result)
            }
    }
    
    fileprivate func uploadMedia(_ data: Data, fileName: String, completion: @escaping (String?) -> Void) {
        
        if !isConnectedToInternet() { return }
        
        self.showSpinner()
        
        let storageRef = Storage.storage().reference().child("chatMedia/\(fileName)")
        
        storageRef.putData(data, metadata: nil) { metadata, error in
            
            if let error = error {
                print("❌ Upload error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                
                if let url = url {
                    completion(url.absoluteString)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    fileprivate func sendMessage(from senderId: String, to recipientId: String, mediaURL: String, thumbnailUrl: String, type: String, text: String) {
        
        if !isConnectedToInternet() { return }
        
        if type.isEmpty {
            self.showSpinner()
        }
        
        self.messageText = ""
        
        self.sendMessageTextView.text = ""
        self.sendMessageTextContainer.layer.borderColor = UIColor.getUnSelectedBorderColor().cgColor
        self.sendMessageTextPlaceholderLabel.isHidden = false
        self.sendMessageTextContainerHeight.constant = self.defaultTextViewHeight
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "mediaURL": mediaURL,
            "mediaType": type,
            "thumbnailURL": thumbnailUrl,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        Firestore.firestore()
            .collection("chats")
            .document(self.chatId)
            .collection("messages")
            .addDocument(data: messageData)
        
        // Update last message for chat preview
        Firestore.firestore().collection("chats").document(self.chatId).updateData([
            "lastMessage": text,
            "lastTimestamp": FieldValue.serverTimestamp()
        ])
        
        self.hideSpinner()
    }
}


// MARK: - UIDocumentMenu & UIDocumentPicker Delegate
extension ChatVC: UIDocumentPickerDelegate {
    
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let selectedFilesCount = urls.count
        
        guard selectedFilesCount <= self.maxAllowedFilesCount else {
            toastMessage(messageStr: "User can select max \(self.maxAllowedFilesCount) files")
            return
        }
        
        guard let docURL = urls.first else {
            return
        }
        
        if docURL.startAccessingSecurityScopedResource() {
            
            if let doctData = try? Data(contentsOf: docURL) {
                let fileName = docURL.lastPathComponent
                self.startUploadingMedia(data: doctData, fileName: fileName, mediaType: MediaType.DOCUMENT, videoUrl: "")
            }
        }
    }
    
    internal func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - SKPhotoBrowser Delegate
extension ChatVC: SKPhotoBrowserDelegate {
    
    @objc func willDismissAtPageIndex(_ index: Int) {
        APPDELEOBJ.isRestrictRotation = true
    }
}


// MARK: - AVPlayerViewController Delegate
extension ChatVC: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        APPDELEOBJ.isRestrictRotation = true
    }
}


// MARK: - Button Touch & Action
extension ChatVC {
    
    @IBAction func attchmentBtnTouch(_ sender: UIButton) {
        
        self.resignAllTextView()
        self.fetchFiles()
    }
    
    @IBAction func cameraBtnTouch(_ sender: Any) {
        
        self.resignAllTextView()
        self.openPickerImage()
    }
    
    @IBAction func sendMessageBtnTouch(_ sender: UIButton) {
        
        self.resignAllTextView()
        
        if !self.messageText.isEmpty,
           let otherUserId = self.otherUser.uid, !otherUserId.isEmpty {
            
            self.sendMessage(from: getDefaultUserId(), to: otherUserId, mediaURL: "", thumbnailUrl: "", type: "", text: self.messageText)
            
        } else {
            toastMessage(messageStr: Constants.Generic.MessageEmpty)
        }
    }
    
    @objc fileprivate func mediaBtnTouch(_ sender: ChatMessageButton) {
        
        self.resignAllTextView()
        
        if let chat = sender.chat {
            
            if let mediaType = chat.mediaType, mediaType == MediaType.DOCUMENT,
               let docStr = chat.mediaURL, !docStr.isEmpty {
                
                let pdfViewerVC = getStoryBoard(identifier: "PDFViewerVC", storyBoardName: Constants.Storyboard.Main) as! PDFViewerVC
                pdfViewerVC.fileUrl = docStr
                pdfViewerVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(pdfViewerVC, animated: true)
                
            } else  if let mediaType = chat.mediaType, mediaType == MediaType.IMAGE,
                       let imageStr = chat.mediaURL, !imageStr.isEmpty {
                
                self.openPhotoViewer(imageStrUrl: imageStr)
                
            } else if let mediaType = chat.mediaType, mediaType == MediaType.VIDEO,
                      let videoStr = chat.mediaURL, !videoStr.isEmpty {
                
                self.openVideoPlayer(videoStr: videoStr)
            }
        }
    }
}


// MARK: -
// MARK: - UITableView DataSource
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView.tag == 0 {
            return self.groupedMessages.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 {
            return self.groupedMessages[section].messages.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        
        let lblDate = UILabel()
        lblDate.backgroundColor = .getButtonBgColor()
        lblDate.textColor = .getButtonTextColor()
        lblDate.font = .systemFont(ofSize: 12, weight: .regular)
        lblDate.textAlignment = .center
        lblDate.translatesAutoresizingMaskIntoConstraints = false
        lblDate.text = formatDateHeader(self.groupedMessages[section].date)
        
        let labelSizeWithFixedWith = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let exactLabelsize = lblDate.sizeThatFits(labelSizeWithFixedWith)
        lblDate.frame = CGRect(origin: CGPoint(x: tableView.frame.width / 2.0, y: 0.0), size: exactLabelsize)
        lblDate.layer.cornerRadius = 5.0
        lblDate.clipsToBounds = true
        
        headerView.backgroundColor = .clear
        headerView.addSubview(lblDate)
        
        NSLayoutConstraint.activate([
            lblDate.widthAnchor.constraint(equalToConstant: lblDate.frame.width + 30),
            lblDate.heightAnchor.constraint(equalToConstant: lblDate.frame.height + 8),
            lblDate.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 1),
            lblDate.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 1)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messages = self.groupedMessages[indexPath.section].messages
        
        if tableView.tag == 0 && indexPath.row < messages.count {
            
            if messages[indexPath.row].senderId == getDefaultUserId() {
                
                var cell = tableView.dequeueReusableCell(withIdentifier: "ChatSelfCell") as? ChatSelfCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("ChatSelfCell", owner: self, options: nil)
                    cell = nib![0] as? ChatSelfCell
                }
                
                cell?.configureCell(messageData: messages[indexPath.row])
                
                cell?.mediaBtn.tag = indexPath.row
                cell?.mediaBtn.addTarget(self, action: #selector(self.mediaBtnTouch(_:)), for: .touchUpInside)
                
                return cell!
                
            } else {
                
                var cell = tableView.dequeueReusableCell(withIdentifier: "ChatOtherCell") as? ChatOtherCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("ChatOtherCell", owner: self, options: nil)
                    cell = nib![0] as? ChatOtherCell
                }
                
                cell?.configureCell(messageData: messages[indexPath.row], userName: self.otherUsername)
                
                cell?.mediaBtn.tag = indexPath.row
                cell?.mediaBtn.addTarget(self, action: #selector(self.mediaBtnTouch(_:)), for: .touchUpInside)
                
                return cell!
            }
            
        } else {
            return getTableCell()
        }
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.resignAllTextView()
    }
}


// MARK: - UITextField Delegate
extension ChatVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.messageText = textView.text
        
        if textView.text.isEmpty {
            self.sendMessageTextPlaceholderLabel?.isHidden = false
        } else {
            self.sendMessageTextPlaceholderLabel?.isHidden = true
        }
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        var height = newSize.height + 10
        if height <= self.defaultTextViewHeight {
            height = self.defaultTextViewHeight
        }
        
        DispatchQueue.main.async {
            self.updateTextViewUI()
            self.sendMessageTextContainerHeight.constant = height
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.location == 0 && (text == "\n" || text == " ") {
            return false
        }
        
        var oldText = ""
        if !textView.text.isEmpty {
            oldText = textView.text
        }
        
        return (oldText.count + text.count) <= self.maxChars
    }
}
