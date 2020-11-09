

import UIKit
import AVFoundation

class QRScanViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var linkBtn: UIButton!
    
    //MARK: - Vars
    //    var captureSession = AVCaptureSession()
    //    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    //    var qrCodeFrameView: UIView?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var selfUrl: URL?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviBar.topItem?.title = "Point the camera at QR-code"
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        view.bringSubviewToFront(naviBar)
        view.bringSubviewToFront(resultLbl)
        
        captureSession.startRunning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        view.bringSubviewToFront(linkBtn)
        linkBtn.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        
        linkBtn.isHidden = true
        
    }
    
    //MARK: - Funcs
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: - Actions
    @IBAction func close(segue: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToLink(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIApplication.shared.open(self.selfUrl!, options: [:], completionHandler: nil)
        }
    }
}
