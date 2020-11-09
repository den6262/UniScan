

import UIKit
import PDFKit
import PDFGenerator

class PDFDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var naviBar: UINavigationBar!
    
    //MARK: - Vars
    var documents = [URL]()
    var pdfNumber = 0
    var pdfTitle = ""
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        documents = Helpers.getDocuments()
        setPDF(pdfURL: documents[pdfNumber])
        naviBar.topItem?.title = pdfTitle
    }
    
    //MARK: - Funcs
    func setPDF(pdfURL: URL) {
        if let pdfDocument = PDFDocument(url: pdfURL) {
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
            pdfView.maxScaleFactor = 3.0
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
            if let page = pdfDocument.page(at: 0) {
                let pageBounds = page.bounds(for: pdfView.displayBox)
                pdfView.scaleFactor = (pdfView.bounds.width) / pageBounds.width
            }
        }
    }
    
    func shareDocument(documentPath: String) {
        if FileManager.default.fileExists(atPath: documentPath){
            let fileURL = URL(fileURLWithPath: documentPath)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
    
    private func setupShareAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true) {
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.shareDocument(documentPath: self.documents[self.pdfNumber].path)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            do {
                let filePath = self.documents[self.pdfNumber]
                try FileManager.default.removeItem(at: filePath)
                
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name("ReloadData"),
                                                object: nil)
            } catch {
                print("Delete error")
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    //MARK: - Actions
    @IBAction func exportButtonTapped(_ sender: Any) {
        setupShareAction()
    }
    
    @IBAction func close(segue: Any) {
        dismiss(animated: true, completion: nil)
    }
}
