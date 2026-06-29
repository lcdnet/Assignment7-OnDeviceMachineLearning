//
//  BarcodeScanView.swift
//  ASSIGNMENT7ODML
//
//  Created by Levi Daniel on 6/28/26.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeScanView: UIViewControllerRepresentable {
    @Binding var scannedBarcode: String?
    @Binding var isShowingError: Bool
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: BarcodeScanView
        var isProcessing = false
        
        init(parent: BarcodeScanView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard !isProcessing else { return }
            isProcessing = true
            
            let request = VNDetectBarcodesRequest { [weak self] request, error in
                defer { self?.isProcessing = false }
                
                if error != nil {
                    DispatchQueue.main.async {
                        self?.parent.isShowingError = true
                    }
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation],
                      let firstBarcode = results.first?.payloadStringValue else { return }
                
                DispatchQueue.main.async {
                    self?.parent.scannedBarcode = firstBarcode
                }
            }
            
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
            try? handler.perform([request])
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return viewController }
        
        if captureSession.canAddInput(videoInput) { captureSession.addInput(videoInput) }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    BarcodeScanView(scannedBarcode: .constant(nil), isShowingError: .constant(false))
}
