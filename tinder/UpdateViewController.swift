//
//  UpdateViewController.swift
//  tinder
//
//  Created by Mahieu Bayon on 25/09/2018.
//  Copyright © 2018 M4m0ut. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userGenderSwitch: UISwitch!
    @IBOutlet weak var interestedGenderSwitch: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.errorLabel.isHidden = true
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            userGenderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWoman = PFUser.current()?["isInterestedInWoman"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedInWoman, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFile {
            
            photo.getDataInBackground(block: { (data, error) in
                
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        
                        self.profileImageView.image = image
                    }
                }
            })
        }
    }
    
    func createWomen() {
        
        let imageUrls = ["https://vignette.wikia.nocookie.net/simpsons/images/6/6f/Titania_%28Official_Image%29.png/revision/latest?cb=20120330175037", "https://vignette.wikia.nocookie.net/simpsonstappedout/images/c/c3/Lady_Duff_Character_Set.png/revision/latest?cb=20150711072005", "https://upload.wikimedia.org/wikipedia/en/thumb/7/76/Edna_Krabappel.png/220px-Edna_Krabappel.png", "https://vignette.wikia.nocookie.net/simpsons/images/c/c9/Sara_Sloane.png/revision/latest?cb=20100708193925", "https://orig00.deviantart.net/9ebd/f/2018/085/3/8/lurleen_lumpkin_tapped_out_by_kareemcarzan-dc71sze.png", "https://vignette.wikia.nocookie.net/simpsons/images/d/d9/Carol_Berrera.JPG/revision/latest?cb=20150810182738", "http://blog.redfin.com/local/wp-content/uploads/sites/2/2007/10/cookie_kwan.png", "https://vignette.wikia.nocookie.net/lossimpson/images/c/c3/Francesca_Terwilliger.png/revision/latest?cb=20090825004524&path-prefix=es", "https://i.skyrock.net/1008/23621008/pics/730212935_small.jpg", "https://vignette.wikia.nocookie.net/simpsons/images/7/73/Mindy_Simmons_updated.png/revision/latest?cb=20140205200229", "https://tstoaddicts.files.wordpress.com/2013/08/miss_springfield.png", "https://vignette.wikia.nocookie.net/simpsons/images/0/08/Amber_Pigal-Simpson.png/revision/latest?cb=20110827070650", "https://vignette.wikia.nocookie.net/simpsons/images/b/b0/Woman_resembling_Homer.png/revision/latest?cb=20141026204206", "https://orig00.deviantart.net/85e3/f/2014/299/c/9/marge_as_the_new_miss_springfield_by_darthraner83-d6y2e23.png", "https://vignette2.wikia.nocookie.net/simpsons/images/d/df/Shauna_Chalmers_Tapped_out.png/revision/latest?cb=20150802232912", "https://tstotopix.files.wordpress.com/2014/08/200px-lindsey_naegle.png", "https://vignette.wikia.nocookie.net/lossimpson/images/d/db/TabithaVixx.png/revision/latest?cb=20100109181530&path-prefix=es", "https://vignette.wikia.nocookie.net/les-simpson-springfield/images/5/50/Paris_Texan.png/revision/latest?cb=20150729220524&path-prefix=fr", "http://progphp.free.fr/QuizramaImages/1902.png"]
        
        var counter = 1
        
        for imageUrl in imageUrls {
            
            counter += 1
            
            if let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url) {
                    
                    let imageFile = PFFile(name: "photo.png", data: data)
                    let user = PFUser()
                    
                    user["photo"] = imageFile
                    user.username = String(counter)
                    user.password = "pass"
                    user["isFemale"] = true
                    user["isInterestedInWoman"] = false

                    user.signUpInBackground(block: { (success, error) in
                        if success {
                            print("Women User created !")
                        }
                    })
                }
            }
        }
    }
  
    @IBAction func updateImageTapped(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    @IBAction func updateTapped(_ sender: Any) {
        
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn
        PFUser.current()?["isInterestedInWoman"] = interestedGenderSwitch.isOn
        
        if let image = profileImageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                
                PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                  
                    if error != nil {
                        
                        var errorMessage = "Update failed - Try Again"
                        
                        if let error = error as NSError? {
                            
                            if let detailError = error.userInfo["error"] as? String {
                                errorMessage = detailError
                            }
                        }
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                        
                    } else {
                        print("Update succesful")
                        
                        self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                    }

                })
            }
        }
    }
}
