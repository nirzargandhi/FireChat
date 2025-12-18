//
//  PDFViewerVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 04/12/25.
//

import UIKit
import PDFKit

class PDFViewerVC: BaseVC {
    
    // MARK: - Properties
    var fileUrl = ""
    
    fileprivate let spinner = HVDOverlayExtended.spinnerOverlay()
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "File Viewer"
        
        // View Background
        self.view.backgroundColor = .getBgColor()
        
        self.createPdfDocument()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        APPDELEOBJ.isRestrictRotation = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APPDELEOBJ.isRestrictRotation = true
    }
}


// MARK: - Call Back
extension PDFViewerVC {
    
    func showSpinner() {
        self.spinner?.show(on: APPDELEOBJ.window)
    }
    
    func hideSpinner() {
        self.spinner?.dismiss()
    }
    
    func showErrorMsg() {
        toastMessage(messageStr: Constants.Generic.SomethingWentWrong)
    }
    
    fileprivate func createPdfView(withFrame frame: CGRect) -> PDFView {
        
        let pdfView = PDFView(frame: frame)
        pdfView.backgroundColor = .getClearColour()
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        
        return pdfView
    }
    
    fileprivate func createPdfDocument() {
        
        if let resourceUrl = URL(string: self.fileUrl) {
            
            if let pdfDocument = PDFDocument(url: resourceUrl) {
                
                self.hideSpinner()
                
                let navbarheight = STATUSBARHEIGHT + getNavBarHeight
                
                let pdfView = self.createPdfView(withFrame: CGRect(x: 0, y: navbarheight, width: SCREENWIDTH, height: SCREENHEIGHT - navbarheight))
                self.view.addSubview(pdfView)
                pdfView.document = pdfDocument
                
                if let pdfScrollView = pdfView.subviews.first as? UIScrollView {
                    pdfScrollView.showsHorizontalScrollIndicator = false
                    pdfScrollView.showsVerticalScrollIndicator = false
                }
                
            } else {
                self.hideSpinner()
                self.showErrorMsg()
            }
        }
    }
    
    fileprivate func showPdfFile(data: Data) {
        
        if let pdfDocument = PDFDocument(data: data) {
            
            self.hideSpinner()
            
            let navbarheight = STATUSBARHEIGHT + getNavBarHeight
            
            let pdfView = self.createPdfView(withFrame: CGRect(x: 0, y: navbarheight, width: SCREENWIDTH, height: SCREENHEIGHT - navbarheight))
            self.view.addSubview(pdfView)
            pdfView.document = pdfDocument
            
            if let pdfScrollView = pdfView.subviews.first as? UIScrollView {
                pdfScrollView.showsHorizontalScrollIndicator = false
                pdfScrollView.showsVerticalScrollIndicator = false
            }
            
        } else {
            self.hideSpinner()
            self.showErrorMsg()
        }
    }
}


// MARK: - Button Touch & Action
extension PDFViewerVC {
    
    override func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
