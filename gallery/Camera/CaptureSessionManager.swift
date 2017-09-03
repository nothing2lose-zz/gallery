//
//  CaptureSessionManager.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

import UIKit
import AVFoundation

protocol CaptureSessionManagerDelegate: class {
    func cameraSessionManagerDidCaptureAllImages()
    func cameraSessionManagerDidCaptureImage()
    func cameraSessionManagerDidFailToCapture()
}

///
/// CaptureSessionManager
///
/// TODO: orientation, focus, etcs...
///
final class CaptureSessionManager {
    private var session: AVCaptureSession!
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    
    private var stillImageOutput: AVCaptureStillImageOutput?
    private(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private(set) var imageDatas: [Data] = []
    private(set) var images: [UIImage] = []
    private var snapshotRequestCount: Int = 0
    private var accessAllowed = false
    
    weak var delegate: CaptureSessionManagerDelegate?
    
    static func requestAccess() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (completion) in
        }
    }
    
    init() {
        session = AVCaptureSession()
//        session.sessionPreset = AVCaptureSessionPresetPhoto
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            device = backCamera
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            // ...
            // The remainder of the session setup will go here...
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session!.canAddOutput(stillImageOutput) {
            session!.addOutput(stillImageOutput)
            // ...
            // Configure the Live Preview here...
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    }
    
    func start() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            accessAllowed = true
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied ||
            status == AVAuthorizationStatus.restricted {
            accessAllowed = false
            session?.stopRunning()
        }

    }
    
    
    // TODO: replace deprecated methods.
    func takeSnapshot() {
        guard accessAllowed else { return }
        
        snapshotRequestCount += 1
        
        // pure image settings
        let settings = [0.0].map {
            (bias:Float) -> AVCaptureAutoExposureBracketedStillImageSettings in
            AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(withExposureTargetBias: bias)
        }
        let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo)
            
        if let videoConnection = videoConnection {
            stillImageOutput?.captureStillImageBracketAsynchronously(from: videoConnection, withSettingsArray: settings, completionHandler: { [weak self] (sampleBuffer, settings, error) in
                
                guard let `self` = self else { return }
                
                self.snapshotRequestCount -= 1
                
                var success = false
                if let sampleBuffer = sampleBuffer {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    if let imageData = imageData, let image = UIImage(data: imageData) {
                        success = true
                        self.imageDatas.append(imageData)
                        self.images.append(image)
                    }
                    
                    //                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    //                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    //                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                }
                
                if success {
                    self.delegate?.cameraSessionManagerDidCaptureImage()
                    if self.snapshotRequestCount == 0 {
                        self.delegate?.cameraSessionManagerDidCaptureAllImages()
                    }
                } else {
                    self.delegate?.cameraSessionManagerDidFailToCapture()
                }
                
                
            })
        } else {
            delegate?.cameraSessionManagerDidFailToCapture()
        }
    }
    
    
//    func takeSnapshot() {
//        
//        snapshotRequestCount += 1
//        
//        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
//            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { [weak self] (sampleBuffer, error) in
//                guard let `self` = self else { return }
//        
//                self.snapshotRequestCount -= 1
//                
//                var success = false
//                if let sampleBuffer = sampleBuffer {
//                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    if let imageData = imageData, let image = UIImage(data: imageData) {
//                        success = true
//                        self.imageDatas.append(imageData)
//                        self.images.append(image)
//                    }
//                    
////                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
////                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
////                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
//                }
//                
//                if success {
//                    self.delegate?.cameraSessionManagerDidCaptureImage()
//                    if self.snapshotRequestCount == 0 {
//                        self.delegate?.cameraSessionManagerDidCaptureAllImages()
//                    }
//                } else {
//                    self.delegate?.cameraSessionManagerDidFailToCapture()
//                }
//                
//                
//            })
//        } else {
//            delegate?.cameraSessionManagerDidFailToCapture()
//        }
//    }
    
    // TODO: fix a bug.
    func flash() {
        
        do {
            guard let device = device, device.hasTorch, device.hasFlash else { return }
            
            try device.lockForConfiguration()
            
            let mode = device.flashMode
            switch mode {
            case .off:
                
                device.torchMode = .on
                device.flashMode = AVCaptureFlashMode.on
                
            case .on:
                
                device.flashMode = AVCaptureFlashMode.off
                device.torchMode = .off
                
            default:
                
                break
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    
    }
    
    func flip() {
        guard let session = session else { return }
        
        session.stopRunning()
        
        do {
            session.beginConfiguration()
            for input in session.inputs {
                if let input = input as? AVCaptureInput {
                    session.removeInput(input)
                }
            }
            let position = input?.device.position == AVCaptureDevicePosition.front ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front
            
            for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                
                if let device = device as? AVCaptureDevice,
                    device.position == position {
                    self.device = device
                    input = try AVCaptureDeviceInput(device: device)
                    session.addInput(input)
                }
            }
            session.commitConfiguration()
            
        } catch {
            print(error)
        }
        
        session.startRunning()

    }
    
    private func resetCaptureDevice(with position: AVCaptureDevicePosition) {
        
    }
    

}
