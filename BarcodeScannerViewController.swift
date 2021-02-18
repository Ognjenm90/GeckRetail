

import UIKit
import AVFoundation

public class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    let euroFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    private var goods:[GoodsViewModel] = []
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice:AVCaptureDevice?
    
    var lastCapturedCode:String?
    
    public var barcodeScanned:((String) -> ())?
    
    private var allowedTypes = [AVMetadataObject.ObjectType.upce,
                                AVMetadataObject.ObjectType.code39,
                                AVMetadataObject.ObjectType.code39Mod43,
                                AVMetadataObject.ObjectType.ean13,
                                AVMetadataObject.ObjectType.ean8,
                                AVMetadataObject.ObjectType.code93,
                                AVMetadataObject.ObjectType.code128,
                                AVMetadataObject.ObjectType.pdf417,
                                AVMetadataObject.ObjectType.qr,
                                AVMetadataObject.ObjectType.aztec]
    
    public override func viewDidLoad() {
        //immer wenn man scannen will wird data aus db aufgerufen und das "goods" Array mit Artikel ausgefüllt wird damit man später die QRCode des Artikel mit dem gescanntem Code vergleichen kann
       
        GoodsData.sharedInstance.callFirebaseToFetchNewData(){
            
            self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
            
            super.viewDidLoad()
            
            
            
        }
        // das Nutzen des Standardgerätes für die Camera
        self.captureDevice = AVCaptureDevice.default(for: .video)
        
        
        var error:NSError?
        let input: AnyObject!
        do {
            if let captureDevice = self.captureDevice {
                input = try AVCaptureDeviceInput(device: captureDevice)
                
                if (error != nil) {
                    //Wenn ein Fehler auftritt, kommt einfach die Beschreibung und es geht nicht mehr weiter.
                    print("\(String(describing: error?.localizedDescription))")
                    return
                }
                
                // Initialisieren CaptureSession-object und input Gerät is fürs Fotografieren bzw. Scannen  gestellt
                captureSession = AVCaptureSession()
                captureSession?.addInput(input as! AVCaptureInput)
                
                // Initialisieren a AVCaptureMetadataOutput-object und stellen das auf Output-Gerät
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.allowedTypes
                
                // Initialisieren Video-preview-layer and hinzufügen es als Sublayer to the viewPreviews Layer.
                
                if let captureSession = captureSession {
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
                    videoPreviewLayer?.frame = videoView.layer.bounds
                    videoView.layer.addSublayer(videoPreviewLayer!)
                    
                    // Starten video capture.
                    captureSession.startRunning()
                    
                    // Stellen Message-label zum Topview
                    view.bringSubview(toFront: messageLabel)
                    
                    // Initialisieren QR Code Frame
                    qrCodeFrameView = UIView()
                    qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
                    qrCodeFrameView?.layer.borderWidth = 2
                    qrCodeFrameView?.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
                    
                    view.addSubview(qrCodeFrameView!)
                    view.bringSubview(toFront: qrCodeFrameView!)
                }
            }
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
    }
    

 
    
    public override func viewDidLayoutSubviews() {
        
    }
    
    
    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
   
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Kein Barcode registriert"
            return
        }
        
      
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
       
            //  Wenn die gefundenen Metadaten den QR-Code-Metadaten entsprechen, aktualisiert es den Text der Statusbezeichnung  und AlertView erstellen auf welchem die der Artikel steht oder die Meldund dass,es dieses Barcod in DB nicht gibt
           
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                var containsBarcode:Bool = false
                for g in goods{
                    
                    
                    if g.ean == metadataObj.stringValue{
                        containsBarcode = true
                        let alertController = UIAlertController(title: "Artikel", message: g.name,preferredStyle: .alert)
                        alertController.view.backgroundColor = UIColor.white
                        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
                        alertController.view.addConstraint(height)
                        
                        let imageView = UIImageView(frame: CGRect(x: 180, y: 75, width: 65, height: 70))
                        imageView.image = UIImage(named:g.image)
                        imageView.backgroundColor = UIColor.clear
                        alertController.view.addSubview(imageView)
                        
                        
                        let rewePriceText = UITextView(frame: CGRect(x: 3, y: 55, width: 200, height: 50))
                        rewePriceText.backgroundColor = UIColor.clear
                        let RewePrice = euroFormatter.string(
                            from: NSNumber(floatLiteral: g.priceRewe))!
                        rewePriceText.text =  "Preis in Rewe: \(RewePrice)"
                        alertController.view.addSubview(rewePriceText)
                        let edekaPriceText = UITextView(frame: CGRect(x: 3, y: 75, width: 200, height: 50))
                        edekaPriceText.backgroundColor = UIColor.clear
                        let EdekaPrice = euroFormatter.string(
                            from: NSNumber(floatLiteral: g.priceEdeka))!
                        edekaPriceText.text =  "Preis in Edeka: \(EdekaPrice)"
                        alertController.view.addSubview(edekaPriceText)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                              (alert: UIAlertAction!) -> Void in
                              // Perform Action
                          })
                          alertController.addAction(okAction)
                        
                          self.present(alertController ,animated: true)
                       break
                        
                    }else{
                        containsBarcode = false
                    }
               
                }
                messageLabel.text = metadataObj.stringValue
                lastCapturedCode = metadataObj.stringValue
                if(!containsBarcode){
                                    let alertController = UIAlertController(title: "Meldung", message: "Dieses Barcode gibt es in DataBase nicht!",preferredStyle: .alert)
                                    alertController.view.backgroundColor = UIColor.white
                                    let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
                                    alertController.view.addConstraint(height)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                                                               (alert: UIAlertAction!) -> Void in
                                                               // Perform Action
                                                           })
                                                           alertController.addAction(okAction)
                                                         
                                                           self.present(alertController ,animated: true)
                                }
            }
        }
    }
    
    
  
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
