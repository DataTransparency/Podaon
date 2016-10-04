
import Foundation
import UIKit
import Firebase
import AVKit
import AVFoundation
import AssetsLibrary


let orientationRaw = UIInterfaceOrientation.landscapeLeft.rawValue

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

class CaptureController: NSObject, AVCapturePhotoCaptureDelegate {
    
    weak var previewView: AVCamPreviewView!
    weak var imageOut: UIImageView!
    
    let SessionRunningAndDeviceAuthorizedContext = "SessionRunningAndDeviceAuthorizedContext"
    let CapturingStillImageContext = "CapturingStillImageContext"
    let RecordingContext = "RecordingContext"
    var session: AVCaptureSession?
    var deviceAuthorized: Bool  = false
    var sessionQueue: DispatchQueue?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoDeviceInput: AVCaptureDeviceInput?
    var backgroundRecordId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    init (previewView: AVCamPreviewView, imageOut: UIImageView){
        self.previewView = previewView
        self.imageOut = imageOut
        
        super.init()
        
        if !Platform.isSimulator {
            let session: AVCaptureSession = AVCaptureSession()
        self.session = session
        self.previewView.session = session
        self.checkDeviceAuthorizationStatus()
        
        let sessionQueue = DispatchQueue(label: "cameraQueue")
        self.sessionQueue = sessionQueue
        sessionQueue.async  { [weak self] in
            self?.backgroundRecordId = UIBackgroundTaskInvalid
            let videoDevice: AVCaptureDevice? = CaptureController.videoDevice()
            var videoDeviceInput: AVCaptureDeviceInput?
            
            var error: NSError? = nil
            do {
                videoDeviceInput  = try AVCaptureDeviceInput(device: videoDevice)
            } catch let error1 as NSError {
                error = error1
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            if (error != nil) {
                print(error)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription
                    , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //self.present(alert, animated: true, completion: nil)
            }
            
            if session.canAddInput(videoDeviceInput){
                session.addInput(videoDeviceInput)
                self?.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    let orientation: AVCaptureVideoOrientation = AVCaptureVideoOrientation(rawValue: orientationRaw)!
                    (self?.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientation
                }
            }
            
            let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
            
            if session.canAddOutput(movieFileOutput){
                session.addOutput(movieFileOutput)
                
                let connection: AVCaptureConnection? = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                let stab = connection?.isVideoStabilizationSupported
                if (stab != nil) {
                    connection!.preferredVideoStabilizationMode = .auto
                }
                self?.movieFileOutput = movieFileOutput
            }
            
            let stillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
            if session.canAddOutput(stillImageOutput) {
                session.addOutput(stillImageOutput)
                self?.stillImageOutput = stillImageOutput
            }
        }
        }
    }
    
    var timer: Timer?
    
    func start(){
        self.sessionQueue?.async {
            self.session?.startRunning()
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.snap), userInfo: nil, repeats: true)
            }
        }
    }
    
    func stop(){
        self.timer?.invalidate()
        self.session?.stopRunning()
    }
    
    
    func snap(){
        if !Platform.isSimulator {
            self.sessionQueue?.async {
                let settings =  AVCapturePhotoSettings()
                settings.flashMode = AVCaptureFlashMode.off
                
                let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: 160,
                                     kCVPixelBufferHeightKey as String: 160,
                                     ]
                settings.previewPhotoFormat = previewFormat
                
                let videoOrientation =  (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation
                self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo).videoOrientation = videoOrientation
                self.stillImageOutput?.capturePhoto(with: settings, delegate: self)
            }
        }
        
    }
    
    @objc(captureOutput:didFinishProcessingPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error:)
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
        else
        {
            if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
                
                let image = UIImage(data: dataImage)
                imageOut.image = image
            }
        }
        
    }
    
    func checkDeviceAuthorizationStatus(){
        let mediaType:String = AVMediaTypeVideo
        AVCaptureDevice.requestAccess(forMediaType: mediaType) { [weak self] (granted: Bool) in
            if granted {
                self?.deviceAuthorized = true;
            } else {
                DispatchQueue.main.async {
                    let alert: UIAlertController = UIAlertController(
                        title: "AVCam",
                        message: "AVCam does not have permission to access camera",
                        preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    //self?.present(alert, animated: true, completion: nil)
                }
                self?.deviceAuthorized = false;
            }
        }
    }
    class func videoDevice() -> AVCaptureDevice? {
        
        let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera ], mediaType: AVMediaTypeVideo , position: .front )
        
        var devices = discoverySession!.devices!
        
        if devices.isEmpty {
            print("This device has no camera. Probably the simulator.")
            return nil
        } else {
            let captureDevice: AVCaptureDevice = devices[0]
            return captureDevice
        }
    }
    
}

