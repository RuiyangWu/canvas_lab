//
//  ViewController.swift
//  canvas_lab
//
//  Created by ruiyang_wu on 8/17/16.
//  Copyright © 2016 ruiyang_wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var trayView: UIView!

  var trayOriginalCenter: CGPoint!

  var trayClosed = false

  var newlyCreatedFace: UIImageView!

  var newFaceOriginalCenter: CGPoint!

  // Drag tray to open/close it
  @IBAction func onTrayPanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    // Absolute (x,y) coordinates in parent view (parentView should be
    // the parent view of the tray)
    let point = panGestureRecognizer.locationInView(view)
    let translation = panGestureRecognizer.translationInView(view)
    let velocity = panGestureRecognizer.velocityInView(view)

    if panGestureRecognizer.state == UIGestureRecognizerState.Began {
      trayOriginalCenter = trayView.center
    } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
      trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
    } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
      UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: { 
            if velocity.y > 0 { // Drag Down - Close Tray
              self.trayView.frame.origin.y = self.view.frame.height - 50 // 568
              self.trayClosed = true
            }
            else { // Drag Up - Open Tray
              self.trayView.frame.origin.y = self.view.frame.height - self.trayView.frame.height // 283
              self.trayClosed = false
            }
        }, completion: nil)
    }
  }

  // Tap tray to open/close it
  @IBAction func onTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
    let point = tapGestureRecognizer.locationInView(view)
    if trayClosed { // Open tray
      self.trayView.frame.origin.y = self.view.frame.height - self.trayView.frame.height // 283
      trayClosed = false
    }
    else { // Close tray
      if point.y < self.trayView.frame.origin.y + 50 {
        self.trayView.frame.origin.y = self.view.frame.height - 50 // 568
        trayClosed = true
      }
    }

  }

  // Drag a face template to create a new face
  @IBAction func panOnFace(panGestureRecognizer: UIPanGestureRecognizer) {
    // Gesture recognizers know the view they are attached to

    if panGestureRecognizer.state == UIGestureRecognizerState.Began {
      let imageView = panGestureRecognizer.view as! UIImageView

      // Create a new image view that has the same image as the one currently panning
      newlyCreatedFace = UIImageView(image: imageView.image)

      // Bonus: add pan gesture recognizer
      let panGestRec = UIPanGestureRecognizer(target: self, action: #selector(ViewController.panOnNewlyCreatedFace(_:)))
      newlyCreatedFace.userInteractionEnabled = true
      newlyCreatedFace.addGestureRecognizer(panGestRec)

      let pinchGestRec = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchOnNewlyCreatedFace(_:)))
      newlyCreatedFace.userInteractionEnabled = true
      newlyCreatedFace.addGestureRecognizer(pinchGestRec)

      let rotateGestRec = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotateOnNewlyCreatedFace(_:)))
      newlyCreatedFace.userInteractionEnabled = true
      newlyCreatedFace.addGestureRecognizer(rotateGestRec)
      rotateGestRec.delegate = self

      // Add the new face to the tray's parent view.
      view.addSubview(newlyCreatedFace)

      // Initialize the position of the new face.
      newlyCreatedFace.center = imageView.center

      // Since the original face is in the tray, but the new face is in the
      // main view, you have to offset the coordinates
      newlyCreatedFace.center.y += trayView.frame.origin.y

      // Remember original point
      newFaceOriginalCenter = newlyCreatedFace.center
    }
    else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
      let translation = panGestureRecognizer.translationInView(view)
      newlyCreatedFace.center.x = newFaceOriginalCenter.x + translation.x
      newlyCreatedFace.center.y = newFaceOriginalCenter.y + translation.y
    }
  }

  // Drag newly created face to move it
  func panOnNewlyCreatedFace(panGestureRecognizer: UIPanGestureRecognizer) {
    // Absolute (x,y) coordinates in parent view
    let newFace = panGestureRecognizer.view!
    var point = panGestureRecognizer.locationInView(view)

    // Relative change in (x,y) coordinates from where gesture began.
    var translation = panGestureRecognizer.translationInView(view)
    var velocity = panGestureRecognizer.velocityInView(view)

    if panGestureRecognizer.state == UIGestureRecognizerState.Began {
      print("Gesture began at: \(point)")
      newFaceOriginalCenter = newFace.center
      newFace.transform = CGAffineTransformMakeScale(1.2, 1.2)
    } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
      print("Gesture changed at: \(point)")
      newFace.center.x = newFaceOriginalCenter.x + translation.x
      newFace.center.y = newFaceOriginalCenter.y + translation.y
    } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
      print("Gesture ended at: \(point)")
      newFace.transform = CGAffineTransformMakeScale(1, 1)
    }
  }

  // Pinch newly created face
  func pinchOnNewlyCreatedFace(pinchGestureRecognizer: UIPinchGestureRecognizer) {
    let scale = pinchGestureRecognizer.scale
    print("Pinch scale: ", scale)
    let newFace = pinchGestureRecognizer.view
    newFace?.transform = CGAffineTransformMakeScale(scale, scale)
  }

  // Rotate newly created face
  func rotateOnNewlyCreatedFace(rotateGestureRecognizer: UIRotationGestureRecognizer) {
    print("Rotation")
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
    return true
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

