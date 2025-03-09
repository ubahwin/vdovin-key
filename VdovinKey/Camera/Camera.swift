#if os(iOS)
import AVFoundation

@available(macCatalyst 14.0, *)
extension AVCaptureDevice {
    private func minimumSubjectDistanceForCode(
        fieldOfView: Float,
        minimumCodeSize: Float,
        previewFillPercentage: Float
    ) -> Float {
        /*
         Given the camera horizontal field of view, we can compute the distance (mm) to make a code
         of minimumCodeSize (mm) fill the previewFillPercentage.
         */
        let radians = (fieldOfView / 2).radians
        let filledCodeSize = minimumCodeSize / previewFillPercentage
        return filledCodeSize / tan(radians)
    }
}

private extension Float {
    var radians: Float {
        self * Float.pi / 180
    }
}
#endif

/*
 Part of this code is copied from Apple sample project "AVCamBarcode: Using AVFoundation to capture barcodes".

 IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 */

#if os(iOS)
import AVFoundation
import SwiftUI

/// An enum describing the ways CodeScannerView can hit scanning problems.
public enum ScanError: Error {
    /// The camera could not be accessed.
    case badInput

    /// The camera was not capable of scanning the requested codes.
    case badOutput

    /// Initialization failed.
    case initError(_ error: Error)

    /// The camera permission is denied
    case permissionDenied
}

/// The result from a successful scan: the string that was scanned, and also the type of data that was found.
/// The type is useful for times when you've asked to scan several different code types at the same time, because
/// it will report the exact code type that was found.
@available(macCatalyst 14.0, *)
public struct ScanResult {
    /// The contents of the code.
    public let string: String

    /// The type of code that was matched.
    public let type: AVMetadataObject.ObjectType

    /// The image of the code that was matched
    public let image: UIImage?

    /// The corner coordinates of the scanned code.
    public let corners: [CGPoint]
}

/// The operating mode for CodeScannerView.
public enum ScanMode {
    /// Scan exactly one code, then stop.
    case once

    /// Scan each code no more than once.
    case oncePerCode

    /// Keep scanning all codes until dismissed.
    case continuous

    /// Keep scanning all codes - except the ones from the ignored list - until dismissed.
    case continuousExcept(ignoredList: Set<String>)

    /// Scan only when capture button is tapped.
    case manual

    var isManual: Bool {
        switch self {
        case .manual:
            return true
        case .once, .oncePerCode, .continuous, .continuousExcept:
            return false
        }
    }
}

/// A SwiftUI view that is able to scan barcodes, QR codes, and more, and send back what was found.
/// To use, set `codeTypes` to be an array of things to scan for, e.g. `[.qr]`, and set `completion` to
/// a closure that will be called when scanning has finished. This will be sent the string that was detected or a `ScanError`.
/// For testing inside the simulator, set the `simulatedData` property to some test data you want to send back.
@available(macCatalyst 14.0, *)
public struct CodeScannerView: UIViewControllerRepresentable {

    public let codeTypes: [AVMetadataObject.ObjectType]
    public let scanMode: ScanMode
    public let manualSelect: Bool
    public let scanInterval: Double
    public let showViewfinder: Bool
    public let requiresPhotoOutput: Bool
    public var simulatedData = ""
    public var shouldVibrateOnSuccess: Bool
    public var isTorchOn: Bool
    public var isPaused: Bool
    public var isGalleryPresented: Binding<Bool>
    public var videoCaptureDevice: AVCaptureDevice?
    public var completion: (Result<ScanResult, ScanError>) -> Void

    public init(
        codeTypes: [AVMetadataObject.ObjectType],
        scanMode: ScanMode = .once,
        manualSelect: Bool = false,
        scanInterval: Double = 2.0,
        showViewfinder: Bool = false,
        requiresPhotoOutput: Bool = true,
        simulatedData: String = "",
        shouldVibrateOnSuccess: Bool = true,
        isTorchOn: Bool = false,
        isPaused: Bool = false,
        isGalleryPresented: Binding<Bool> = .constant(false),
        videoCaptureDevice: AVCaptureDevice? = AVCaptureDevice.bestForVideo,
        completion: @escaping (Result<ScanResult, ScanError>) -> Void
    ) {
        self.codeTypes = codeTypes
        self.scanMode = scanMode
        self.manualSelect = manualSelect
        self.showViewfinder = showViewfinder
        self.requiresPhotoOutput = requiresPhotoOutput
        self.scanInterval = scanInterval
        self.simulatedData = simulatedData
        self.shouldVibrateOnSuccess = shouldVibrateOnSuccess
        self.isTorchOn = isTorchOn
        self.isPaused = isPaused
        self.isGalleryPresented = isGalleryPresented
        self.videoCaptureDevice = videoCaptureDevice
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController(showViewfinder: showViewfinder, parentView: self)
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.parentView = self
        uiViewController.updateViewController(
            isTorchOn: isTorchOn,
            isGalleryPresented: isGalleryPresented.wrappedValue,
            isManualCapture: scanMode.isManual,
            isManualSelect: manualSelect
        )
    }

}

@available(macCatalyst 14.0, *)
extension CodeScannerView {

    @available(*, deprecated, renamed: "requiresPhotoOutput")
    public var requirePhotoOutput: Bool {
        requiresPhotoOutput
    }
}

@available(macCatalyst 14.0, *)
struct CodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            // do nothing
        }
    }
}
#endif


#if os(iOS)
import AVFoundation
import UIKit

@available(macCatalyst 14.0, *)
extension CodeScannerView {

    public final class ScannerViewController: UIViewController, UINavigationControllerDelegate {
        private let photoOutput = AVCapturePhotoOutput()
        private var isCapturing = false
        private var handler: ((UIImage?) -> Void)?
        var parentView: CodeScannerView!
        var codesFound = Set<String>()
        var didFinishScanning = false
        var lastTime = Date(timeIntervalSince1970: 0)
        private let showViewfinder: Bool

        let fallbackVideoCaptureDevice = AVCaptureDevice.default(for: .video)

        private var isGalleryShowing: Bool = false {
            didSet {
                // Update binding
                if parentView.isGalleryPresented.wrappedValue != isGalleryShowing {
                    parentView.isGalleryPresented.wrappedValue = isGalleryShowing
                }
            }
        }

        public init(showViewfinder: Bool = false, parentView: CodeScannerView) {
            self.parentView = parentView
            self.showViewfinder = showViewfinder
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            self.showViewfinder = false
            super.init(coder: coder)
        }

        func openGallery() {
            isGalleryShowing = true
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.presentationController?.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }

        @objc func openGalleryFromButton(_ sender: UIButton) {
            openGallery()
        }

        #if targetEnvironment(simulator)
        override public func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = true

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            label.textAlignment = .center

            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Select a custom image", for: .normal)
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.setTitleColor(UIColor.gray, for: .highlighted)
            button.addTarget(self, action: #selector(openGalleryFromButton), for: .touchUpInside)

            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 50
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(button)

            view.addSubview(stackView)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            // Send back their simulated data, as if it was one of the types they were scanning for
            found(ScanResult(
                string: parentView.simulatedData,
                type: parentView.codeTypes.first ?? .qr, image: nil, corners: []
            ))
        }

        #else

        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer!

        private lazy var viewFinder: UIImageView? = {
            let imageView = UIImageView(image: UIImage(systemName: "viewfinder.rectangular"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()

        private lazy var manualCaptureButton: UIButton = {
            let button = UIButton(type: .system)
            let image = UIImage(systemName: "microbe.circle.fill")
            button.setBackgroundImage(image, for: .normal)
            button.addTarget(self, action: #selector(manualCapturePressed), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

        private lazy var manualSelectButton: UIButton = {
            let button = UIButton(type: .system)
            let image = UIImage(systemName: "photo.on.rectangle")
            let background = UIImage(systemName: "capsule.fill")?.withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
            button.setBackgroundImage(background, for: .normal)
            button.addTarget(self, action: #selector(openGalleryFromButton), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

        override public func viewDidLoad() {
            super.viewDidLoad()
            self.addOrientationDidChangeObserver()
            self.setBackgroundColor()
            self.handleCameraPermission()
        }

        override public func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }

        @objc func updateOrientation() {
            guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession?.connections.last, connection.isVideoOrientationSupported else { return }
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
            }
        }

        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateOrientation()
        }

        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            setupSession()
        }

        private func setupSession() {
            guard let captureSession else {
                return
            }

            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }

            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            addViewFinder()

            reset()

            if !captureSession.isRunning {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.startRunning()
                }
            }
        }

        private func handleCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .restricted:
                    break
                case .denied:
                    self.didFail(reason: .permissionDenied)
                case .notDetermined:
                    self.requestCameraAccess {
                        self.setupCaptureDevice()
                        DispatchQueue.main.async {
                            self.setupSession()
                        }
                    }
                case .authorized:
                    self.setupCaptureDevice()
                    self.setupSession()

                default:
                    break
            }
        }

        private func requestCameraAccess(completion: (() -> Void)?) {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                guard status else {
                    self?.didFail(reason: .permissionDenied)
                    return
                }
                completion?()
            }
        }

        private func addOrientationDidChangeObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateOrientation),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
        }

        private func setBackgroundColor(_ color: UIColor = .black) {
            view.backgroundColor = color
        }

        private func setupCaptureDevice() {
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice else {
                return
            }

            do {
                try videoCaptureDevice.lockForConfiguration()
            } catch {
                return
            }

            videoCaptureDevice.videoZoomFactor = 1.0
            videoCaptureDevice.unlockForConfiguration()

            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                didFail(reason: .initError(error))
                return
            }

            if captureSession!.canAddInput(videoInput) {
                captureSession!.addInput(videoInput)
            } else {
                didFail(reason: .badInput)
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()

            if captureSession!.canAddOutput(metadataOutput) {
                captureSession!.addOutput(metadataOutput)
                captureSession!.addOutput(photoOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = parentView.codeTypes
            } else {
                didFail(reason: .badOutput)
                return
            }
        }

        private func addViewFinder() {
            guard showViewfinder, let imageView = viewFinder else { return }

            view.addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 200),
                imageView.heightAnchor.constraint(equalToConstant: 200),
            ])
        }

        override public func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            if captureSession?.isRunning == true {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.stopRunning()
                }
            }

            NotificationCenter.default.removeObserver(self)
        }

        override public var prefersStatusBarHidden: Bool {
            true
        }

        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            .all
        }

        /** Touch the screen for autofocus */
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard touches.first?.view == view,
                  let touchPoint = touches.first,
                  let device = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice,
                  device.isFocusPointOfInterestSupported
            else { return }

            let videoView = view
            let screenSize = videoView!.bounds.size
            let xPoint = touchPoint.location(in: videoView).y / screenSize.height
            let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
            let focusPoint = CGPoint(x: xPoint, y: yPoint)

            do {
                try device.lockForConfiguration()
            } catch {
                return
            }

            // Focus to the correct point, make continuous focus and exposure so the point stays sharp when moving the device closer
            device.focusPointOfInterest = focusPoint
            device.focusMode = .continuousAutoFocus
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.unlockForConfiguration()
        }

        @objc func manualCapturePressed(_ sender: Any?) {
            self.readyManualCapture()
        }

        func showManualCaptureButton(_ isManualCapture: Bool) {
            if manualCaptureButton.superview == nil {
                view.addSubview(manualCaptureButton)
                NSLayoutConstraint.activate([
                    manualCaptureButton.heightAnchor.constraint(equalToConstant: 60),
                    manualCaptureButton.widthAnchor.constraint(equalTo: manualCaptureButton.heightAnchor),
                    view.centerXAnchor.constraint(equalTo: manualCaptureButton.centerXAnchor),
                    view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: manualCaptureButton.bottomAnchor, constant: 32)
                ])
            }

            view.bringSubviewToFront(manualCaptureButton)
            manualCaptureButton.isHidden = !isManualCapture
        }

        func showManualSelectButton(_ isManualSelect: Bool) {
            if manualSelectButton.superview == nil {
                view.addSubview(manualSelectButton)
                NSLayoutConstraint.activate([
                    manualSelectButton.heightAnchor.constraint(equalToConstant: 50),
                    manualSelectButton.widthAnchor.constraint(equalToConstant: 60),
                    view.centerXAnchor.constraint(equalTo: manualSelectButton.centerXAnchor),
                    view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: manualSelectButton.bottomAnchor, constant: 32)
                ])
            }

            view.bringSubviewToFront(manualSelectButton)
            manualSelectButton.isHidden = !isManualSelect
        }
        #endif

        func updateViewController(isTorchOn: Bool, isGalleryPresented: Bool, isManualCapture: Bool, isManualSelect: Bool) {
            guard let videoCaptureDevice = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice else {
                return
            }

            if videoCaptureDevice.hasTorch {
                try? videoCaptureDevice.lockForConfiguration()
                videoCaptureDevice.torchMode = isTorchOn ? .on : .off
                videoCaptureDevice.unlockForConfiguration()
            }

            if isGalleryPresented, !isGalleryShowing {
                openGallery()
            }

            #if !targetEnvironment(simulator)
            showManualCaptureButton(isManualCapture)
            showManualSelectButton(isManualSelect)
            #endif
        }

        public func reset() {
            codesFound.removeAll()
            didFinishScanning = false
            lastTime = Date(timeIntervalSince1970: 0)
        }

        public func readyManualCapture() {
            guard parentView.scanMode.isManual else { return }
            self.reset()
            lastTime = Date()
        }

        var isPastScanInterval: Bool {
            Date().timeIntervalSince(lastTime) >= parentView.scanInterval
        }

        var isWithinManualCaptureInterval: Bool {
            Date().timeIntervalSince(lastTime) <= 0.5
        }

        func found(_ result: ScanResult) {
            lastTime = Date()

            if parentView.shouldVibrateOnSuccess {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }

            parentView.completion(.success(result))
        }

        func didFail(reason: ScanError) {
            parentView.completion(.failure(reason))
        }

    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

@available(macCatalyst 14.0, *)
extension CodeScannerView.ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {


        guard let metadataObject = metadataObjects.first,
              !parentView.isPaused,
              !didFinishScanning,
              !isCapturing,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {

            return
        }

        handler = { [weak self] image in
            guard let self else { return }
            let result = ScanResult(string: stringValue, type: readableObject.type, image: image, corners: readableObject.corners)

            switch parentView.scanMode {
            case .once:
                found(result)
                // make sure we only trigger scan once per use
                didFinishScanning = true

            case .manual:
                if !didFinishScanning, isWithinManualCaptureInterval {
                    found(result)
                    didFinishScanning = true
                }

            case .oncePerCode:
                if !codesFound.contains(stringValue) {
                    codesFound.insert(stringValue)
                    found(result)
                }

            case .continuous:
                if isPastScanInterval {
                    found(result)
                }

            case .continuousExcept(let ignoredList):
                if isPastScanInterval, !ignoredList.contains(stringValue) {
                    found(result)
                }
            }
        }

        if parentView.requiresPhotoOutput {
            isCapturing = true
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        } else {
            handler?(nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

@available(macCatalyst 14.0, *)
extension CodeScannerView.ScannerViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        isGalleryShowing = false

        defer {
            dismiss(animated: true)
        }

        guard let qrcodeImg = info[.originalImage] as? UIImage,
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let ciImage = CIImage(image:qrcodeImg) else {

            return
        }

        var qrCodeLink = ""

        let features = detector.features(in: ciImage)

        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink = feature.messageString!
            if qrCodeLink.isEmpty {
                didFail(reason: .badOutput)
            } else {
                let corners = [
                    feature.bottomLeft,
                    feature.bottomRight,
                    feature.topRight,
                    feature.topLeft
                ]
                let result = ScanResult(string: qrCodeLink, type: .qr, image: qrcodeImg, corners: corners)
                found(result)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isGalleryShowing = false
        dismiss(animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

@available(macCatalyst 14.0, *)
extension CodeScannerView.ScannerViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Gallery is no longer being presented
        isGalleryShowing = false
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

@available(macCatalyst 14.0, *)
extension CodeScannerView.ScannerViewController: AVCapturePhotoCaptureDelegate {

    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        isCapturing = false
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
        }
        guard let qrImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
        }
        handler?(qrImage)
    }

    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }

    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }

}

// MARK: - AVCaptureDevice

@available(macCatalyst 14.0, *)
public extension AVCaptureDevice {

    /// This returns the Ultra Wide Camera on capable devices and the default Camera for Video otherwise.
    static var bestForVideo: AVCaptureDevice? {
        let deviceHasUltraWideCamera = !AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.isEmpty
        return deviceHasUltraWideCamera ? AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) : AVCaptureDevice.default(for: .video)
    }

}
#endif
