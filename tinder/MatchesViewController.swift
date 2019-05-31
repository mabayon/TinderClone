//
//  MatchesViewController.swift
//  tinder
//
//  Created by Mahieu Bayon on 27/09/2018.
//  Copyright © 2018 M4m0ut. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var images: [UIImage] = []
    var userIds: [String] = []
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query() {
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            
            if let acceptedPeedps = PFUser.current()?["accepted"] as? [String] {
                query.whereKey("objectId", containedIn: acceptedPeedps)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if let users = objects {
                        for user in users {
                            if let theUser = user as? PFUser {
                                if let imageFile = theUser["photo"] as? PFFile {
                                    
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        
                                        if let imageData = data  {
                                            if let image = UIImage(data: imageData) {
                                                
                                                if let objectId = theUser.objectId {
                                                    
                                                    let messageQuery = PFQuery(className: "Message")
                                                    
                                                    messageQuery.whereKey("recipent", equalTo: PFUser.current()!.objectId!)
                                                    messageQuery.whereKey("sender", equalTo: objectId)
                                                    
                                                    messageQuery.findObjectsInBackground(block: { (objects, error) in
                                                        var messageText = "You haven't recieved a message yet"
                                                        
                                                        if let object = objects {
                                                            for message in object {
                                                                if let content = message["content"] as? String {
                                                                    messageText = content
                                                                }
                                                            }
                                                        }
                                                        self.images.append(image)
                                                        self.userIds.append(objectId)
                                                        self.messages.append(messageText)
                                                        self.tableView.reloadData()
                                                    })
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
            }
        }
        
        
    }
   
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchesTableViewCell {
            
//            cell.messageLabel.text = "You haven't received a message yet"
            cell.profileImageView.image = images[indexPath.row]
            cell.recipentObjectId = userIds[indexPath.row]
            cell.messageLabel.text = messages[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
}
