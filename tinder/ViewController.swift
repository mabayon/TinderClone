//
//  ViewController.swift
//  tinder
//
//  Created by Mahieu Bayon on 25/09/2018.
//  Copyright © 2018 M4m0ut. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var matchImageView: UIImageView!
    
    var displayUserID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        matchImageView.addGestureRecognizer(gesture)
        
        updateImage()
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            
            if let point = geoPoint {
                
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
        }
    }
  
    @IBAction func logoutTapped(_ sender: Any) {
     
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let labelPoint = gestureRecognizer.translation(in: view)
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / -200)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var scaleAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        matchImageView.transform = scaleAndRotated
        
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            
            if matchImageView.center.x < (view.bounds.width / 2 - 100) {
                print("Not interested")
                acceptedOrRejected = "rejected"
            }
            if matchImageView.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserID != "" {
                
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    
                    if success {
                        print("Success")
                        self.updateImage()
                    }
                })
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            scaleAndRotated = rotation.scaledBy(x: 1, y: 1)
            
            matchImageView.transform = scaleAndRotated
            matchImageView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }

    func updateImage() {
        
        if let query = PFUser.query() {
        
            if let isInterestedInWoman = PFUser.current()?["isInterestedInWoman"] {
                query.whereKey("isFemale", equalTo: isInterestedInWoman)
            }
            
            if let isFemale = PFUser.current()?["isFemale"] {
                query.whereKey("isInterestedInWoman", equalTo: isFemale)
            }
            
            var ignoredUsers: [String] = []
            
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {
                ignoredUsers += acceptedUsers
            }
            
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }

            query.whereKey("objectId", notContainedIn: ignoredUsers)

            if let geoPoint = PFUser.current()?["location"] as? PFGeoPoint {
                
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1, longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1, longitude: geoPoint.longitude + 1))
            }
            
            query.limit = 1
            
            query.findObjectsInBackground { (objects, error) in
                
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                
                                imageFile.getDataInBackground(block: { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        self.matchImageView.image = UIImage(data: imageData)
                                      
                                        if let userID = user.objectId {
                                            self.displayUserID = userID
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}

