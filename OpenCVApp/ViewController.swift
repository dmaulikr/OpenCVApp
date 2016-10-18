//
//  ViewController.swift
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/11/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, SCNSceneRendererDelegate {
    let kPOINTS_1 = 50
    let kPOINTS_2 = 100
    let kPOINTS_3 = 250
    let kPOINTS_4 = 500
    let kPOINTS_5 = 1000
    
    let openCVWrapper = OpenCVWrapper()
    let box = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 1.0)
    let redMaterial = SCNMaterial()

    private var cameraSession: AVCaptureSession = AVCaptureSession()
    private var imageView:UIImageView?
    private var sceneView:SCNView!
    private var imageOrientation:UIImageOrientation = UIImageOrientation.right
    private var boxNode:SCNNode!
    private var arView:ARView!
    private var targetViewWidth:CGFloat = 0.0
    private var targetViewHeight:CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setImageOrientation(orientation: UIApplication.shared.statusBarOrientation)
        
        redMaterial.diffuse.contents = SKColor.red
        
        let image = UIImage(named: "art.scnassets/images/heightmap.png")
        let processedImage = OpenCVWrapper.processImage(withOpenCV: image)
        imageView = UIImageView(image: processedImage)
        
        imageView!.frame = CGRect.zero
        view.addSubview(imageView!)
        
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        // Create a bottom space constraint
        var constraint = NSLayoutConstraint (item: imageView!,
                                             attribute: NSLayoutAttribute.bottom,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: view,
                                             attribute: NSLayoutAttribute.bottom,
                                             multiplier: 1,
                                             constant: 0)
        view.addConstraint(constraint)
        
        // Create a top space constraint
        constraint = NSLayoutConstraint (item: imageView!,
                                         attribute: NSLayoutAttribute.top,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: view,
                                         attribute: NSLayoutAttribute.top,
                                         multiplier: 1,
                                         constant: 0)
        view.addConstraint(constraint)
        
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: imageView!,
                                         attribute: NSLayoutAttribute.right,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: view,
                                         attribute: NSLayoutAttribute.right,
                                         multiplier: 1,
                                         constant: 0)
        view.addConstraint(constraint)
        
        // Create a left space constraint
        constraint = NSLayoutConstraint (item: imageView!,
                                         attribute: NSLayoutAttribute.left,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: view,
                                         attribute: NSLayoutAttribute.left,
                                         multiplier: 1,
                                         constant: 0)
        view.addConstraint(constraint)
        
        self.setup()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        setImageOrientation(orientation: UIApplication.shared.statusBarOrientation)
    }

    private func setImageOrientation(orientation:UIInterfaceOrientation) {
        switch(orientation) {
        case UIInterfaceOrientation.portraitUpsideDown:
            imageOrientation = UIImageOrientation.left
        case UIInterfaceOrientation.portrait:
            imageOrientation = UIImageOrientation.right
            break
        case UIInterfaceOrientation.landscapeLeft:
            imageOrientation = UIImageOrientation.down
            break
        case UIInterfaceOrientation.landscapeRight:
            imageOrientation = UIImageOrientation.up
            break
        default:
            break
        }
    }
    
    private func setup() {
        self.addSCNView()
        self.loadCamera()
        self.startCamera()
        
        let trackerImage = UIImage(named: "art.scnassets/images/target.jpg")!
        
        openCVWrapper.createPatternDetector(trackerImage)
        let _ = Timer.scheduledTimer(timeInterval: (1.0/20.0), target:self, selector: #selector(updateTracking), userInfo: nil, repeats: true)
        
        let arFrame = CGRect(x:0, y:0, width:trackerImage.size.width, height:trackerImage.size.height)
        self.arView = ARView(frame: arFrame)
        self.view.addSubview(self.arView)
        self.arView.hide()
        
        // Save Visualization Layer Dimensions
        targetViewWidth = self.arView.frame.size.width;
        targetViewHeight = self.arView.frame.size.height
    }
    
    @objc private func updateTracking() {
        if(openCVWrapper.isTracking()) {
            print("YES, Match Value is \(openCVWrapper.matchValue())")
            let point = openCVWrapper.matchPoint()
            self.arView.center = CGPoint(x:point.x + targetViewWidth / 2.0,
                                         y:point.y + targetViewHeight / 2.0)
            self.arView.show()
            
        } else {
            print("NO, Match Value is \(openCVWrapper.matchValue())")
            self.arView.hide()
        }
    }
    
    private func addSCNView() {
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        let scnView = SCNView(frame:self.view.frame, options:nil)
        scnView.backgroundColor = UIColor.clear
        scnView.isOpaque = false
        self.imageView!.addSubview(scnView)
        
        // set the scene to the view
        scnView.scene = SCNScene()
        scnView.delegate = self
        scnView.showsStatistics = true
        
        //Create overlay scene
        let overlay = SKScene(size:(scnView.bounds.size))
        scnView.overlaySKScene = overlay
        let hudNode = HUDNode(scene:overlay, size: overlay.size)
        overlay.addChild(hudNode)
        
        self.sceneView = scnView
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        sceneView.scene?.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor.darkGray
        sceneView.scene?.rootNode.addChildNode(ambientLightNode)
        
        
        sceneView.play(self)

    }
    
    private func loadCamera() {
        let captureSessionResult = self.createCaptureSession()
        
        if captureSessionResult.error == nil && captureSessionResult.session != nil {
            self.cameraSession = captureSessionResult.session!
        }
        else {
            fatalError("Cannot create capture session, check if device is capable for augmented reality.")
        }
    }
    
    // Try to find back video device and add video input to it. This method can be used to check if device has hardware available for augmented reality.
    private func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) {
        var error: NSError?
        var captureSession: AVCaptureSession?
        var backVideoDevice: AVCaptureDevice?
        let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        
        // Get back video device
        for captureDevice in videoDevices! {
            if (captureDevice as AnyObject).position == AVCaptureDevicePosition.back {
                backVideoDevice = captureDevice as? AVCaptureDevice
                break
            }
        }
        if backVideoDevice != nil {
            var videoInput: AVCaptureDeviceInput!
            do {
                videoInput = try AVCaptureDeviceInput(device: backVideoDevice)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
            }
            if error == nil {
                captureSession = AVCaptureSession()
                
                if captureSession!.canAddInput(videoInput) {
                    captureSession!.addInput(videoInput)
                }
                else {
                    error = NSError(domain: "OpenCVApp", code: 10002, userInfo: ["description": "Error adding video input."])
                }
            }
            else {
                error = NSError(domain: "OpenCVApp", code: 10001, userInfo: ["description": "Error creating capture device input."])
            }
        }
        else {
            error = NSError(domain: "OpenCVApp", code: 10000, userInfo: ["description": "Back video device not found."])
        }
        
        return (session: captureSession, error: error)
    }
    
    private func startCamera() {
        self.addVideoDataOutput()
        self.cameraSession.startRunning()
    }
    
    private func stopCamera() {
        self.cameraSession.stopRunning()
    }
    
    private func addVideoDataOutput() {
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)]
        captureOutput.alwaysDiscardsLateVideoFrames = true
        
        let serialQueue = DispatchQueue(label: "opencv.queue")
        captureOutput.setSampleBufferDelegate(self, queue: serialQueue)
        
        self.cameraSession.addOutput(captureOutput)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //process frame
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let stride = CVPixelBufferGetBytesPerRow(imageBuffer)
        
        DispatchQueue.main.sync {
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
                .union(.byteOrder32Little)
            let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: stride, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
            
            // Construct CGImageRef from CGContextRef
            let newImage = newContext.makeImage()!
            
            // Construct UIImage from CGImageRef
            let image = UIImage(cgImage: newImage, scale:1.0, orientation:imageOrientation)
            imageView!.image = image
        }
        
        let i8 = baseAddress?.assumingMemoryBound(to: UInt8.self)
        openCVWrapper.scanFrame(i8, width: width, height: height, stride: stride)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = sceneView else {
            return
        }
        for touch in touches {
            let location:CGPoint = touch.location(in: view.overlaySKScene!)
            let node:SKNode = view.overlaySKScene!.atPoint(location)
            if let name = node.name { // Check if node name is not nil
                if(name == "attackNode") {
                    //let ring = self.selectRandomRing()
                    //let ctr = self.crosshairs.center
                    
                    let ctr = CGPoint(x:0, y:0)
                    let targetHit = self.arView.convert(ctr, from:self.view)
                    let ring = self.arView.selectBestRing(point: targetHit)
                    
                    print("Ring value is \(ring)")
                    switch ( ring ) {
                    case 5: // Bullseye
                        self.hitTargetWithPoints(points: kPOINTS_5)
                        break
                    case 4:
                        self.hitTargetWithPoints(points: kPOINTS_4)
                        break
                    case 3:
                        self.hitTargetWithPoints(points: kPOINTS_3)
                        break
                    case 2:
                        self.hitTargetWithPoints(points: kPOINTS_2)
                        break
                    case 1: // Outermost Ring
                        self.hitTargetWithPoints(points: kPOINTS_1)
                        break
                    case 0: // Miss Target
                        self.missTarget()
                        break
                    default:
                        break
                    }
                }
                break
            }
        }
    }
    
    func selectRandomRing() -> Int {
        // Simulate a 50% chance of hitting the target
        let randomNumber1 = arc4random() % 100
        if ( randomNumber1 < 50 ) {
            // Stagger the 5 simulations linearly
            let randomNumber2 = arc4random() % 100
            if ( randomNumber2 < 20 ) {
                return 1 /* outer most ring */
            } else if ( randomNumber2 < 40 ) {
                return 2
            } else if ( randomNumber2 < 60 ) {
                return 3
            } else if ( randomNumber2 < 80 ) {
                return 4
            } else {
                return 5 /* bullseye */
            }
        } else {
            return 0
        }
    }
    
    private func hitTargetWithPoints(points:Int) {
        //Play sound
        //Update score
        //Show explosion
        
        boxNode = SCNNode(geometry: box)
        boxNode.geometry?.firstMaterial = redMaterial
        boxNode.position = SCNVector3(x:0.0, y:0.0, z:0.0)
        sceneView.scene?.rootNode.addChildNode(boxNode)
        let moveAction = SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1)
        let explosionAction = SCNAction.run({_ in
            let explosion = SCNParticleSystem(named: "fire.scnp", inDirectory: "art.scnassets")!
            let node = SCNNode()
            self.sceneView.scene?.rootNode.addChildNode(node)
            node.position = self.boxNode.position
            node.addParticleSystem(explosion)
        })
        let removeAction = SCNAction.run({_ in self.boxNode.removeFromParentNode()})
        let sequence = SCNAction.sequence([moveAction,explosionAction, removeAction])
        boxNode.runAction(sequence)
    }
    
    private func missTarget() {
        //Play missed sound
    }
}

