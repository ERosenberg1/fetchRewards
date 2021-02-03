//
//  ViewController.swift
//  Fetch Rewards iOS Challenge
//
//  Created by Eric  Rosenberg on 1/29/21.
//

import UIKit


class eventTableController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    private var Events: [Event] = []
    private var filteredData: [Event] = []
    var eventID = Int()
    var searching = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var eventTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchTextField.textColor = .black
        searchBar.delegate = self
        eventTable.delegate = self
        eventTable.dataSource = self
        hideKeyboardWhenTappedAround()

        fetchEvents() { events in
            self.Events = events
            DispatchQueue.main.async {
                self.eventTable.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // deselect the selected row if any
        let selectedRow: IndexPath? = eventTable.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            eventTable.deselectRow(at: selectedRowNotNill, animated: true)
            eventTable.reloadData()
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
        searchBar.text = nil
        searching = false 
        self.eventTable.reloadData()
    }
    
    func fetchEvents(completionHandler: @escaping(([Event]) -> Void)) {
        var Events = [Event]()
        guard let url = URL(string: "https://api.seatgeek.com/2/events?client_id=MjE1MjE3MzR8MTYxMTk3OTE5MC45MTgyNzI3&client_secret=472c432b7f1cb8ad5b042b94c74de32e7b0a41db83b069e34d5fbcf5f0328e09") else { return }

        self.getData(from: url) { [self] data, response, error in
          guard let data = data, error == nil else { return }
          let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let dictionary = jsonData as? [String:Any] {
                let events = dictionary["events"]! as! [[String : AnyObject]]
                for i in 0..<events.count {
                    let title = events[i]["short_title"]!
                    let location = events[i]["venue"]!["name"]!!
                    let dateDict = events[i]["datetime_local"]!
                    let date = self.convertDateFormatter(date: dateDict as! String)
                    let performers = events[i]["performers"]! as! [[String : AnyObject]]
                    let imageURL = URL(string: performers[0]["image"]! as! String)
                    self.getData(from: imageURL!) { data,respone, error in
                        guard let data = data, error == nil else { return }
                        let image = UIImage(data: data)
                        Events.append(Event(title:title as! String, location: location as! String, date: date as! String, image: image!,favorite: false))
                        if i == events.count - 1 {
                            completionHandler(Events)
                        }
                    }
                }
            }
        }
    }
    
    func convertDateFormatter(date: String) -> String {
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
     dateFormatter.locale = Locale(identifier: "your_loc_id")
     let convertedDate = dateFormatter.date(from: date)
     guard dateFormatter.date(from: date) != nil else {
     assert(false, "no date from string")
     return ""
     }
     dateFormatter.dateFormat = "E, d MMM YYYY h:mm a"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
     let timeStamp = dateFormatter.string(from: convertedDate!)
     return timeStamp
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
   func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        if searching {
            numberOfRow = filteredData.count
        } else {
            numberOfRow = Events.count
        }
        return numberOfRow
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            var height:CGFloat = CGFloat()
            height = 148.0
            return height
        }
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let eventImage = cell.viewWithTag(4) as! UIImageView
        let eventTitle = cell.viewWithTag(1) as! UILabel
        let eventLocation = cell.viewWithTag(2) as! UILabel
        let eventDate = cell.viewWithTag(3) as! UILabel
        let favorite = cell.viewWithTag(5) as! UIImageView
        
        if searching {
            eventImage.image = filteredData[indexPath.row].image
            eventImage.layer.cornerRadius = eventImage.frame.size.height/8
            eventTitle.text = filteredData[indexPath.row].title
            eventTitle.textColor = UIColor.black
            eventTitle.textAlignment = .left
            eventTitle.font = UIFont.boldSystemFont(ofSize: 23)
            eventTitle.adjustsFontSizeToFitWidth = true
            eventLocation.text = filteredData[indexPath.row].location
            eventLocation.textColor = UIColor.gray
            eventLocation.textAlignment = .left
            eventDate.text = filteredData[indexPath.row].date
            eventDate.textColor = UIColor.gray
            eventDate.textAlignment = .left
            if filteredData[indexPath.row].favorite == false {
                favorite.isHidden = true
            }
            else {
                favorite.isHidden = false
            }
        } else {
            eventImage.image = Events[indexPath.row].image
            eventImage.layer.cornerRadius = eventImage.frame.size.height/8
            eventTitle.text = Events[indexPath.row].title
            eventTitle.textColor = UIColor.black
            eventTitle.textAlignment = .left
            eventTitle.font = UIFont.boldSystemFont(ofSize: 23)
            eventTitle.adjustsFontSizeToFitWidth = true
            eventLocation.text = Events[indexPath.row].location
            eventLocation.textColor = UIColor.gray
            eventLocation.textAlignment = .left
            eventDate.text = Events[indexPath.row].date
            eventDate.textColor = UIColor.gray
            eventDate.textAlignment = .left
            if Events[indexPath.row].favorite == false {
                favorite.isHidden = true
            }
            else {
                favorite.isHidden = false
            }
        }
        return cell
     }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventID = indexPath.row
        performSegue(withIdentifier: "toEventDetails", sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = Events.filter{ ($0.title.range(of: searchText, options: .caseInsensitive) != nil) || $0.location.localizedCaseInsensitiveContains(searchText) || $0.date.localizedCaseInsensitiveContains(searchText)}
        if searchText.isEmpty {
           searching = false
        } else {
            searching = true
        }
        print(filteredData)
        eventTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toEventDetails") {
            let vc = segue.destination as! detailedEventController
            if searching == true {
                vc.event = filteredData[eventID]
            } else {
                vc.event = Events[eventID]
            }
            
            vc.callback = { event in
                for i in 0..<self.Events.count {
                    if self.Events[i].title == event.title {
                        self.Events.remove(at: i)
                        self.Events.insert(event, at: i)
                    }
                }
            }
        }
    }
 
}

struct Event {
    let title: String
    let location: String
    let date: String
    let image: UIImage
    var favorite: Bool
}
