

import UIKit
import PDFGenerator

class ImageDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var naviBar: UINavigationBar!
    
    //MARK: - Vars
    var imgNumber = 0
    var documents = [URL]()
    var imageTitle = ""
    
    var isLockOrNot = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        documents = Helpers.getDocuments()
        imageView.image = UIImage(contentsOfFile: documents[imgNumber].path)
        naviBar.topItem?.title = imageTitle
    }
    
    //MARK: - Funcs
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            if let firstViewController = self.navigationController?.viewControllers.first {
                self.navigationController?.popToViewController(firstViewController, animated: true)
            }
        }))
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
    func shareDocument(documentPath: String) {
        if FileManager.default.fileExists(atPath: documentPath){
            let fileURL = URL(fileURLWithPath: documentPath)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.popoverPresentationController?.sourceView = self.view
            }
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("Document was not found")
        }
    }
    
    func generatePDF(imagePath: String, pdfName: String) {
        let page1 = PDFPage.imagePath(imagePath)
        let pages = [page1]
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("\(pdfName).pdf")
        
        do {
            try PDFGenerator.generate(pages, to: docURL, dpi: .dpi_300)
            showAlertWith(title: "Congratulations!!!", message: "Your image has been saved as PDF.")
            NotificationCenter.default.post(name: NSNotification.Name("ReloadData"),
                                            object: nil)
        } catch (let e) {
            showAlertWith(title: "Save error", message: "Error saving as PDF.")
            print(e)
        }
    }
    
    func setupShareAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true) {
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.shareDocument(documentPath: self.documents[self.imgNumber].path)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Save to Photo Album", style: .default, handler: { action in
            if let image = UIImage(contentsOfFile: self.documents[self.imgNumber].path) {
                MyAlbum.shared.save(image: image)
                self.showAlertWith(title: "Super!!!", message: "Your image has been saved to your Photo Album.")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Generate PDF", style: .default, handler: { action in
            
            self.isLockOrNot = UserDefaults.standard.bool(forKey: "unlock")
            
            if self.isLockOrNot {
                var documentTitle = self.documents[self.imgNumber].path.components(separatedBy: "Documents/")[1]
                documentTitle = String(Array(documentTitle)[0..<(documentTitle.count-4)])
                let imagePath = self.documents[self.imgNumber].path
                self.generatePDF(imagePath: imagePath, pdfName: documentTitle)
            } else {
                self.showAlertWith(title: "Sorry!", message: "This feature is only available in the Pro version of the app(")
            }
            
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            do {
                let filePath = self.documents[self.imgNumber]
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
