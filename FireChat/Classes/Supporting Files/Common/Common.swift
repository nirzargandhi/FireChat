//
//  Common.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestore
import IQKeyboardManagerSwift
import Photos
import SDWebImage

// MARK: - UI / Device Related Functions
func getStoryBoard(identifier: String, storyBoardName: String) -> UIViewController {
    return UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
}

func getBottomSafeAreaHeight() -> CGFloat {
    return (UIDevice.current.hasNotch == true) ? (WINDOWSCENE?.windows.first?.safeAreaInsets.bottom ?? 0) : 0
}


// MARK: - Keyboard Appearance
func keyboardAppearance() {
    
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.toolbarTintColor = .getBgColor()
    IQKeyboardManager.shared.keyboardAppearance = UIKeyboardAppearance.default
}


// MARK: - SDImage Cache Clear
func sdImageCacheClear() {
    
    // SDImageCache.shared.clearMemory()
    // SDImageCache.shared.clearDisk(onCompletion: nil)
    SDImageCache.shared.config.maxDiskAge = 1800
}


//MARK: - Toast Message
func toastMessage(messageStr : String) {
    
    guard let window = APPDELEOBJ.window else {
        return
    }
    
    guard !messageStr.isEmpty else {
        return
    }
    
    DispatchQueue.main.async {
        
        let imgvIcon = UIImageView()
        imgvIcon.contentMode = .scaleAspectFit
        imgvIcon.image = UIImage(named: "InfoIcon")?.withRenderingMode(.alwaysTemplate)
        imgvIcon.tintColor = .getBgColor()
        imgvIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let lblMessage = UILabel()
        lblMessage.backgroundColor = .clear
        lblMessage.numberOfLines = 0
        lblMessage.lineBreakMode = .byWordWrapping
        lblMessage.font = .systemFont(ofSize: 14, weight: .regular)
        lblMessage.textAlignment = .natural
        lblMessage.textColor = .getBgColor()
        lblMessage.text = messageStr
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        
        let vMessage = UIView()
        vMessage.frame = CGRect.zero
        vMessage.layer.cornerRadius = 5
        vMessage.clipsToBounds = true
        vMessage.backgroundColor = .getTextColor()
        
        let labelSizeWithFixedWith = CGSize(width: SCREENWIDTH - 72.0, height: CGFloat.greatestFiniteMagnitude)
        let exactLabelsize = lblMessage.sizeThatFits(labelSizeWithFixedWith)
        lblMessage.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: exactLabelsize)
        
        let sizeLblMessage : CGSize = lblMessage.intrinsicContentSize
        vMessage.frame = CGRect(x: 8.0, y: window.safeAreaInsets.top + 24.0, width: SCREENWIDTH - 16.0, height: lblMessage.frame.height + sizeLblMessage.height + 8.0)
        
        vMessage.addSubview(imgvIcon)
        vMessage.addSubview(lblMessage)
        
        NSLayoutConstraint.activate([
            imgvIcon.leadingAnchor.constraint(equalTo: vMessage.leadingAnchor, constant: 16),
            
            lblMessage.topAnchor.constraint(equalTo: vMessage.topAnchor, constant: 12),
            lblMessage.leadingAnchor.constraint(equalTo: vMessage.leadingAnchor, constant: 40),
            lblMessage.trailingAnchor.constraint(equalTo: vMessage.trailingAnchor, constant: -16),
            lblMessage.bottomAnchor.constraint(equalTo: vMessage.bottomAnchor, constant: -12),
        ])
        
        imgvIcon.widthAnchor.constraint(equalToConstant: 14.0).isActive = true
        imgvIcon.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
        imgvIcon.centerYAnchor.constraint(equalTo: vMessage.centerYAnchor).isActive = true
        
        window.addSubview(vMessage)
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: {
            vMessage.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                vMessage.alpha = 0
            }, completion: { finished in
                vMessage.removeFromSuperview()
            })
        })
    }
}


// MARK: - Set Root SignInVC
func setRootSignInVC() {
    let signInVC = getStoryBoard(identifier: "SignInVC", storyBoardName: Constants.Storyboard.Main) as! SignInVC
    APPDELEOBJ.setRootViewController(rootVC: signInVC)
}


// MARK: - Set Root HomeVC
func setRootHomeVC() {
    let homeVC = getStoryBoard(identifier: "HomeVC", storyBoardName: Constants.Storyboard.Main) as! HomeVC
    APPDELEOBJ.setRootViewController(rootVC: homeVC)
}


// MARK: - Text Width
func getTextWidth(text: String, font: UIFont) -> CGSize {
    let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
    return size
}


// MARK: - Get Table Cell
func getTableCell() -> UITableViewCell {
    
    let cell = UITableViewCell()
    cell.backgroundColor = .getClearColour()
    cell.selectionStyle = .none
    return cell
}


// MARK: - Multi UnderLine Attributed String
func multiUnderLineAttributedString(strings: [String],
                                    fonts: [UIFont],
                                    colors: [UIColor],
                                    alignments: [NSTextAlignment] = [.center],
                                    isUnderline: [Bool] = [false],
                                    lineSpace: CGFloat = 0.0) -> NSMutableAttributedString {
    
    var finalstr = ""
    for str in strings {
        finalstr += str
    }
    
    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: finalstr)
    
    var i = 0
    var j = 0
    
    for font in fonts where j < strings.count {
        attributeString.addAttribute(NSAttributedString.Key.font,
                                     value: font,
                                     range: NSRange(
                                        location: i,
                                        length: strings[j].count))
        
        i += strings[j].count
        j += 1
    }
    
    j = 0
    i = 0
    for color in colors where j < strings.count {
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor,
                                     value: color,
                                     range: NSRange(
                                        location: i,
                                        length: strings[j].count))
        
        i += strings[j].count
        j += 1
    }
    
    j = 0
    i = 0
    for align in alignments where j < strings.count {
        
        let style = NSMutableParagraphStyle()
        style.alignment = align
        style.lineSpacing = lineSpace
        
        attributeString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                     value: style,
                                     range: NSRange(
                                        location: i,
                                        length: strings[j].count))
        
        
        i += strings[j].count
        j += 1
    }
    
    j = 0
    i = 0
    for underline in isUnderline where j < strings.count {
        attributeString.addAttribute(NSAttributedString.Key.underlineStyle,
                                     value: underline,
                                     range: NSRange(
                                        location: i,
                                        length: strings[j].count))
        
        i += strings[j].count
        j += 1
    }
    
    return attributeString
}


// MARK: - Get Initials
func getInitials(from name: String) -> String {
    
    let components = name
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .whitespaces)
        .filter { !$0.isEmpty }
    
    guard !components.isEmpty else { return "" }
    
    return components
        .prefix(2)
        .compactMap { $0.first }
        .map { String($0).uppercased() }
        .joined()
}


// MARK: - Date Formatter
func dateFormatter(date: Date, dateformat: String = Constants.DateTimeFormatter.date1) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
    dateFormatter.dateFormat = dateformat
    return dateFormatter.string(from: date as Date)
}

func formatDateHeader(_ date: Date) -> String {
    
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
        return "Today"
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // e.g. "13 Oct 2025"
        return formatter.string(from: date)
    }
}


// MARK: - Verify URL
func verifyUrl(urlString: String?) -> Bool {
    
    if let urlString = urlString, let url = URL(string: urlString) {
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}


// MARK: - Image and Video Methods
func preloadImages(images: [String]) {
    
    for image in images {
        let imageView = UIImageView(frame: .zero)
        imageView.sd_setImage(with: URL(string: image))
    }
}

func getVideoData(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
    
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat
    
    PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, audioMix, info in
        guard let urlAsset = avAsset as? AVURLAsset else {
            completion(nil)
            return
        }
        
        do {
            let data = try Data(contentsOf: urlAsset.url)
            completion(data)
        } catch {
            print("Error loading video data: \(error)")
            completion(nil)
        }
    }
}

func generateThumbnailFromFirebase(urlString: String, completion: @escaping (UIImage?) -> Void) {
    
    guard let url = URL(string: urlString) else { completion(nil); return }
    
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    DispatchQueue.global().async {
        
        do {
            
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                completion(image)
            }
            
        } catch {
            print("❌ Thumbnail error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}


// MARK: - Firebase Related Methods
func clearFirestoreCache() {
    
    // Use default Firestore settings
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    
    let db = Firestore.firestore()
    db.clearPersistence { error in
        if let error = error {
            print("❌ Failed to clear Firestore cache: \(error)")
        } else {
            print("✅ Firestore cache cleared successfully")
        }
    }
}

func addAnalyticsEvent(eventName: String, params: [String: Any]) {
    Analytics.logEvent(eventName, parameters: params)
}

func getDefaultUserId() -> String {
    
    if let user = Auth.auth().currentUser {
        return user.uid
    }
    
    return ""
}

func getDefaultEmailId() -> String {
    
    if let user = Auth.auth().currentUser,
       let emailId = user.email, !emailId.isEmpty {
        return emailId
    }
    
    return ""
}

func fetchCurrentUserName(completion: @escaping (String?) -> Void) {
    
    guard let uid = Auth.auth().currentUser?.uid else {
        completion(nil)
        return
    }
    
    let db = Firestore.firestore()
    db.collection("users").document(uid).getDocument { snapshot, error in
        
        if let error = error {
            print("❌ Error fetching user:", error.localizedDescription)
            completion(nil)
            return
        }
        
        guard let data = snapshot?.data() else {
            print("⚠️ No user data found")
            completion(nil)
            return
        }
        
        var userName = ""
        if let firstName = data["firstName"] as? String, !firstName.isEmpty {
            userName = firstName
        }
        
        if let lastName = data["lastName"] as? String, !lastName.isEmpty {
            userName = !userName.isEmpty ? (userName + " " + lastName) : lastName
        }
        
        completion(userName)
    }
}

func getDefaultUserName() {
    
    fetchCurrentUserName { userName in
        
        if let name = userName, !name.isEmpty {
            defaultUserName = name
        } else {
            defaultUserName = "SU"
        }
    }
}
