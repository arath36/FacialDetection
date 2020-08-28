//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AVFoundation
import CoreVideo
import AVFoundation


import Firebase

@objc(CameraViewController)
class CameraViewController: UIViewController {
  let systemSoundID: SystemSoundID = 1304
    
  var alertCount = 0
  var successCount = 0
  var minsSuccessful = 0
  var timesAlerted = 0
  var alerted = false
    
  private let detectors: [Detector] = [
    .onDeviceAutoMLImageLabeler,
    .onDeviceFace,
    .onDeviceText,
    .onDeviceObjectProminentNoClassifier,
    .onDeviceObjectProminentWithClassifier,
    .onDeviceObjectMultipleNoClassifier,
    .onDeviceObjectMultipleWithClassifier,
  ]

  private var currentDetector: Detector = .onDeviceFace
  private var isUsingFrontCamera = true
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private lazy var captureSession = AVCaptureSession()
  private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
  private lazy var vision = Vision.vision()
  private var lastFrame: CMSampleBuffer?
  private lazy var modelManager = ModelManager.modelManager()
  @IBOutlet var downloadProgressView: UIProgressView!

    @IBOutlet weak var decisionPicture: UIImageView!
    
    @IBOutlet weak var endRideView: UIView!
    @IBOutlet weak var decisionTitle: UILabel!
    
    @IBOutlet weak var decisionText: UILabel!
    // MARK: - IBOutlets

  @IBOutlet private weak var cameraView: UIView!

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCaptureSessionOutput()
    setUpCaptureSessionInput()
    endRideView.layer.cornerRadius = 25

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    startSession()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    stopSession()
  }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? Drive2ViewController {
            var trip = Trip()
            trip.alerts = timesAlerted
            trip.successfulSeconds = minsSuccessful
            vc.tripData = trip
        }
    }



  @objc
  private func remoteModelDownloadDidSucceed(_ notification: Notification) {
    let notificationHandler = {
      self.downloadProgressView.isHidden = true
      guard let userInfo = notification.userInfo,
        let remoteModel = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? RemoteModel
      else {
        print(
          "firebaseMLModelDownloadDidSucceed notification posted without a RemoteModel instance.")
        return
      }
      print(
        "Successfully downloaded the remote model with name: \(remoteModel.name). The model "
          + "is ready for detection.")
    }
    if Thread.isMainThread { notificationHandler();return }
    DispatchQueue.main.async { notificationHandler() }
  }

  @objc
  private func remoteModelDownloadDidFail(_ notification: Notification) {
    let notificationHandler = {
      self.downloadProgressView.isHidden = true
      guard let userInfo = notification.userInfo,
        let remoteModel = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? RemoteModel,
        let error = userInfo[ModelDownloadUserInfoKey.error.rawValue] as? NSError
      else {
        print(
          "firebaseMLModelDownloadDidFail notification posted without a RemoteModel instance or error."
        )
        return
      }
      print("Failed to download the remote model with name: \(remoteModel.name), error: \(error).")
    }
    if Thread.isMainThread { notificationHandler();return }
    DispatchQueue.main.async { notificationHandler() }
  }

  // MARK: Other On-Device Detections

  private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
    let options = VisionFaceDetectorOptions()

    // When performing latency tests to determine ideal detection settings,
    // run the app in 'release' mode to get accurate performance metrics
    options.landmarkMode = .none
    options.contourMode = .all
    options.classificationMode = .all

    options.performanceMode = .fast
    let faceDetector = vision.faceDetector(options: options)

    var detectedFaces: [VisionFace]? = nil
    do {
      detectedFaces = try faceDetector.results(in: image)
    } catch let error {
      print("Failed to detect faces with error: \(error.localizedDescription).")
    }
    guard let faces = detectedFaces, !faces.isEmpty else {
      print("On-Device face detector returned no results.")
      DispatchQueue.main.sync {
       // self.removeDetectionAnnotations()
        decisionPicture.image = UIImage(named: "icons8-profile-face-100")
          decisionTitle.text = "Eyes not Deteced"
          decisionText.text = "Please face the road when possible."
      }
      return
    }

    DispatchQueue.main.sync {
     // self.removeDetectionAnnotations()
      for face in faces {
        let normalizedRect = CGRect(
          x: face.frame.origin.x / width,
          y: face.frame.origin.y / height,
          width: face.frame.size.width / width,
          height: face.frame.size.height / height
        )

       // self.addContours(for: face, width: width, height: height)
        
        
        if face.hasRightEyeOpenProbability && face.hasLeftEyeOpenProbability {
            if face.rightEyeOpenProbability > 0.4 && face.leftEyeOpenProbability > 0.4 {
                self.alertCount = 0;
                self.successCount = successCount + 1
                self.alerted = false
            } else {
                self.alertCount = alertCount + 1
            }
        }
        if (alertCount > 30) {
           // print ("ALERT")
            if (alerted == false) {
                self.timesAlerted = timesAlerted + 1
                print (timesAlerted)
            }
            self.alerted = true
            self.successCount = 0
            decisionPicture.image = UIImage(named: "icons8-warning-shield-100")
            decisionTitle.text = "ALERT!"
            decisionText.text = "Don't lose your focus. "
            AudioServicesPlaySystemSound (self.systemSoundID)
        } else {
           // print("GOOD JOB")
            decisionPicture.image = UIImage(named: "icons8-happy-100")
            decisionText.text = "Stay focused to keep growing your rewards."
            decisionTitle.text = "Great Job!"
        }
        
        if (successCount > 20) {
            // min of success
            minsSuccessful = minsSuccessful + 1
            successCount = 0
            print (minsSuccessful)
        }
        
        
      }
    }
  }
      // MARK: - Private
    

    @IBAction func endRideButtonPressed(_ sender: Any) {
        
    }
    
  private func setUpCaptureSessionOutput() {
    sessionQueue.async {
      self.captureSession.beginConfiguration()
      // When performing latency tests to determine ideal capture settings,
      // run the app in 'release' mode to get accurate performance metrics
      self.captureSession.sessionPreset = AVCaptureSession.Preset.medium

      let output = AVCaptureVideoDataOutput()
      output.videoSettings = [
        (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA,
      ]
      let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
      output.setSampleBufferDelegate(self, queue: outputQueue)
      guard self.captureSession.canAddOutput(output) else {
        print("Failed to add capture session output.")
        return
      }
      self.captureSession.addOutput(output)
      self.captureSession.commitConfiguration()
    }
  }

  private func setUpCaptureSessionInput() {
    sessionQueue.async {
      let cameraPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
      guard let device = self.captureDevice(forPosition: cameraPosition) else {
        print("Failed to get capture device for camera position: \(cameraPosition)")
        return
      }
      do {
        self.captureSession.beginConfiguration()
        let currentInputs = self.captureSession.inputs
        for input in currentInputs {
          self.captureSession.removeInput(input)
        }

        let input = try AVCaptureDeviceInput(device: device)
        guard self.captureSession.canAddInput(input) else {
          print("Failed to add capture session input.")
          return
        }
        self.captureSession.addInput(input)
        self.captureSession.commitConfiguration()
      } catch {
        print("Failed to create capture device input: \(error.localizedDescription)")
      }
    }
  }

  private func startSession() {
    sessionQueue.async {
      self.captureSession.startRunning()
    }
  }

  private func stopSession() {
    sessionQueue.async {
      self.captureSession.stopRunning()
    }
  }

  private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    if #available(iOS 10.0, *) {
      let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .unspecified
      )
      return discoverySession.devices.first { $0.position == position }
    }
    return nil
  }

  private func presentDetectorsAlertController() {
    let alertController = UIAlertController(
      title: Constant.alertControllerTitle,
      message: Constant.alertControllerMessage,
      preferredStyle: .alert
    )
    detectors.forEach { detectorType in
      let action = UIAlertAction(title: detectorType.rawValue, style: .default) {
        [unowned self] (action) in
        guard let value = action.title else { return }
        guard let detector = Detector(rawValue: value) else { return }
        self.currentDetector = detector
      }
      if detectorType.rawValue == currentDetector.rawValue { action.isEnabled = false }
      alertController.addAction(action)
    }
    alertController.addAction(UIAlertAction(title: Constant.cancelActionTitleText, style: .cancel))
    present(alertController, animated: true)
  }



}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("Failed to get image buffer from sample buffer.")
      return
    }
    lastFrame = sampleBuffer
    let visionImage = VisionImage(buffer: sampleBuffer)
    let metadata = VisionImageMetadata()
    let orientation = UIUtilities.imageOrientation(
      fromDevicePosition: isUsingFrontCamera ? .front : .back
    )

    let visionOrientation = UIUtilities.visionImageOrientation(from: orientation)
    metadata.orientation = visionOrientation
    visionImage.metadata = metadata
    let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
    let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
    var shouldEnableClassification = false
    var shouldEnableMultipleObjects = false
    switch currentDetector {
    case .onDeviceObjectProminentWithClassifier, .onDeviceObjectMultipleWithClassifier:
      shouldEnableClassification = true
    default:
      break
    }
    switch currentDetector {
    case .onDeviceObjectMultipleNoClassifier, .onDeviceObjectMultipleWithClassifier:
      shouldEnableMultipleObjects = true
    default:
      break
    }

    switch currentDetector {
    case .onDeviceFace:
      detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
    default:
        print (" ")
    }
  }
}

// MARK: - Constants

public enum Detector: String {
  case onDeviceAutoMLImageLabeler = "On-Device AutoML Image Labeler"
  case onDeviceFace = "On-Device Face Detection"
  case onDeviceText = "On-Device Text Recognition"
  case onDeviceObjectProminentNoClassifier = "ODT for prominent object, only tracking"
  case onDeviceObjectProminentWithClassifier = "ODT for prominent object with classification"
  case onDeviceObjectMultipleNoClassifier = "ODT for multiple objects, only tracking"
  case onDeviceObjectMultipleWithClassifier = "ODT for multiple objects with classification"
}

private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.firebaseml.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.firebaseml.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let remoteAutoMLModelName = "remote_automl_model"
  static let localModelManifestFileName = "automl_labeler_manifest"
  static let autoMLManifestFileType = "json"
  static let labelConfidenceThreshold: Float = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
}

struct Trip {
    var alerts: Int
    var successfulSeconds: Int
    var mileage: Float
    var time: Timestamp?
    init() {
        alerts = 0
        successfulSeconds = 0
        mileage = 0
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time1 = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        time = Timestamp(date: time1 as Date)
    }
}
