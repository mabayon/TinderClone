//
//  MatchesTableViewCell.swift
//  tinder
//
//  Created by Mahieu Bayon on 27/09/2018.
//  Copyright © 2018 M4m0ut. All rights reserved.
//

import UIKit
import Parse

class MatchesTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
   
    var recipentObjectId = ""
    
    @IBAction func sendTapped(_ sender: Any) {
        
        let message = PFObject(className: "Message")
        
        message["sender"] = PFUser.current()?.objectId
        message["recipent"] = recipentObjectId
        message["content"] = messageTextField.text
        messageTextField.text = ""
        
        message.saveInBackground()
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
