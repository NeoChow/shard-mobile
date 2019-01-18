/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import AVFoundation
import SnapKit

protocol ScanViewControllerDelegate {
    func didScan(url: URL)
}

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    static let MinHeight: CGFloat = 50.0
    
    private let cameraQueue = DispatchQueue(label: "camera")
    private var previewLayer: CALayer? = nil
    private let preview = UIView()
    
    private var captureSession: AVCaptureSession? = nil
    public var paused: Bool = false {
        didSet {
            if let captureSession = captureSession {
                cameraQueue.async {
                    if (self.paused) {
                        captureSession.stopRunning()
                    } else {
                        captureSession.startRunning()
                    }
                }
            }
        }
    }
    
    var delegate: ScanViewControllerDelegate? = nil
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.paused = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.paused = false
    }
    
    override func loadView() {
        let view = UIView()
        view.clipsToBounds = true
        
        preview.backgroundColor = .black
        view.addSubview(preview)
        preview.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        let qrCodeContainer = UIView()
        qrCodeContainer.backgroundColor = .white
        qrCodeContainer.layer.cornerRadius = 3
        view.addSubview(qrCodeContainer)
        qrCodeContainer.snp.makeConstraints {
            $0.left.equalTo(view).offset(20)
            $0.bottom.equalTo(view).offset(-20)
            $0.top.greaterThanOrEqualTo(view).offset(20)
            $0.width.equalTo(30)
            $0.height.equalTo(30)
        }
        
        let qrCode = UIImageView()
        qrCode.image = UIImage(named: "qr")
        qrCode.contentMode = .center
        qrCodeContainer.addSubview(qrCode)
        qrCode.snp.makeConstraints {
            $0.width.equalTo(18)
            $0.height.equalTo(18)
            $0.center.equalTo(qrCodeContainer)
        }
        
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let previewLayer = previewLayer {
            previewLayer.frame = CGRect(
                x: 0,
                y: -(UIScreen.main.bounds.height - view.bounds.height) / 2,
                width: self.view.bounds.width,
                height: self.view.bounds.height
            )
        } else {
            if (TARGET_OS_SIMULATOR == 0) {
                startCamera()
            }
        }
    }
    
    func startCamera() {
        let captureDevice = AVCaptureDevice.default(for: .video)
        let input = try! AVCaptureDeviceInput(device: captureDevice!)
        
        let captureSession = AVCaptureSession()
        captureSession.addInput(input)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [.qr]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CGRect(
            x: 0,
            y: -(UIScreen.main.bounds.height - view.bounds.height) / 2,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        preview.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        self.captureSession = captureSession
        if (!paused) {
            DispatchQueue.global().async {
                captureSession.startRunning()
            }
        }
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if paused {
            return
        }
        
        let objects = metadataObjects.filter { $0.type == .qr }
        guard objects.count == 1 else {
            return
        }

        let object = objects[0] as! AVMetadataMachineReadableCodeObject

        guard let shardPath = object.stringValue, let url = URL(string: "https://playground.shardlib.com/api/shards/\(shardPath)") else {
            return
        }
        
        delegate?.didScan(url: url)
    }
}
