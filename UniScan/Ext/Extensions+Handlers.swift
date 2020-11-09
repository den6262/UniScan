

import UIKit
import Foundation
import PDFKit
import WeScan
import AVFoundation

// Extension for UIColor

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

// Extension for UINavigationController

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// Extensions for UIView

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

// Extensions of UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout in AllFilesVC

extension AllFilesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! DocumentCell
        let documentPath = documents[indexPath.row].path
        let documentExtensition = documentPath.suffix(3)
        let title = documentPath.components(separatedBy: "Documents/")[1]
        cell.label.layer.masksToBounds = true
        cell.label.layer.cornerRadius = 5
        cell.documentType.layer.masksToBounds = true
        cell.documentType.layer.cornerRadius = 5
        cell.label.text = String(Array(title)[0..<(title.count-4)])
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0.9179827571, alpha: 1)
        cell.layer.borderWidth = 2.2
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 4.5
        cell.layer.shadowOpacity = 2.1
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.masksToBounds = false
        
        if documentExtensition == "jpg" {
            cell.imageView.image = UIImage(contentsOfFile: documentPath)
            cell.documentType.text = "JPG"
        } else if documentExtensition == "pdf" {
            if let pdfDocument = PDFDocument(url: documents[indexPath.row]) {
                if let page1 = pdfDocument.page(at: 0) {
                    cell.imageView.image = page1.thumbnail(of: CGSize(
                                                            width: cell.imageView.frame.size.width*4,
                                                            height: cell.imageView.frame.size.height*4), for: .trimBox)
                }
            }
            cell.documentType.text = "PDF"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentExtensition = documents[indexPath.row].path.suffix(3)
        documentOrderNumber = indexPath.row
        if documentExtensition == "jpg" {
            performSegue(withIdentifier: "imageDetail", sender: nil)
        } else if documentExtensition == "pdf" {
            performSegue(withIdentifier: "pdfDetail", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
}

// Extensions of ImageScannerControllerDelegate in PDFScanViewController

extension PDFScanViewController: ImageScannerControllerDelegate {
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        if results.doesUserPreferEnhancedImage {
            scannedImage = results.enhancedImage
        } else {
            scannedImage = results.scannedImage
        }
        scanner.dismiss(animated: true, completion: nil)
        showSaveDialog(scannedImage: scannedImage)
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        let scannerVC = ImageScannerController()
        scannerVC.imageScannerDelegate = self
        present(scannerVC, animated: true, completion: nil)
    }
    
}

// Extensions of UIScrollViewDelegate in ImageDetailViewController

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

// Extensions of AVCaptureMetadataOutputObjectsDelegate in QRScanViewController

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        //dismiss(animated: true)
    }
    
    func found(code: String) {
        if code != nil {
            
            if let url = URL(string: code) {
                
                selfUrl = url
                resultLbl.text = code
                linkBtn.isHidden = false
                
            } else {
                linkBtn.isHidden = true
                resultLbl.text = code
            }
        }
    }
}

// Button Animations

class AnimateBtn: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animateBtn()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        animateBtn()
    }
    
    
    private func animateBtn() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.88
        pulse.toValue = 1.03
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
    }
}
