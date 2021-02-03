//
//  detailedView.swift
//  Fetch Rewards iOS Challenge
//
//  Created by Eric  Rosenberg on 1/29/21.
//

import UIKit

class detailedEventController: UIViewController {
    var event = Event(title: String(), location: String(), date: String(), image: UIImage(), favorite:Bool())
    var callback : ((Event) -> Void)?
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventDateTime: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var favoriteBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventName.text = event.title
        eventName.adjustsFontSizeToFitWidth = true
        eventName.textAlignment = .left
        eventPhoto.image = event.image
        eventPhoto.layer.cornerRadius = eventPhoto.frame.size.height/16
        eventDateTime.text = event.date
        eventLocation.text = event.location
        eventLocation.textColor = .gray
        if event.favorite == true {
            favoriteBttn.setImage(UIImage(named:"heart.fill"),for: UIControl.State.selected)
            favoriteBttn.tintColor = .red
        }
    }
    @IBAction func backAction(_ sender: Any) {
        callback?(event)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func favoriteAction(_ sender: Any) {
        if event.favorite == false {
            favoriteBttn.setImage(UIImage(named: "heart.fill"), for: UIControl.State.selected)
            favoriteBttn.tintColor = .red
            event.favorite = true
        }
        else {
            favoriteBttn.setImage(UIImage(named: "heart"), for: UIControl.State.selected)
            favoriteBttn.tintColor = .black
            event.favorite = false
        }

    }
    
}

