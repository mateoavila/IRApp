//
//  ViewController.swift
//  IRApp
//
//  Created by Mateo Avila on 5/11/21.
//

import UIKit
import AVKit
import Vision

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let captureButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let restartButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restart", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFilledButton(captureButton)
        restartButton.alpha = 0
        Utilities.styleHollowButton(restartButton)
       
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        setupIdentifierConfidenceLabel()
        setupIdentifierConfidenceButton()
        setupIdentifierConfidenceRestartButton()
    }
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 22).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupIdentifierConfidenceButton() {
        view.addSubview(captureButton)
        captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        captureButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captureButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captureButton.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
    }
    
    fileprivate func setupIdentifierConfidenceRestartButton() {
        view.addSubview(restartButton)
        restartButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        restartButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        restartButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        restartButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())
        
       guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        

        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)%"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @objc func captureTapped(){
        print("captured  image")
        
        captureSession.stopRunning()
        
        restartButton.alpha = 1
        captureButton.alpha = 0
        
        
    
    }
    
    @objc func restartTapped(){
        captureSession.startRunning()
        print("image recognigition in progress")
        captureButton.alpha = 1
        restartButton.alpha = 0
    }
    

}
