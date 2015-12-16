
//
//  ViewController.swift
//  Tarea: Petición al servidor openlibrary.org
//
//  Created by Nivardo Ibarra on 11/25/15.
//  Copyright © 2015 Nivardo Ibarra. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtfISBN: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthors: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtfISBN.delegate = self
        txtfISBN.clearButtonMode = .WhileEditing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resetElements() {
        self.lblTitle.text = ""
        self.lblAuthors.text = ""
        self.imgCover.image = UIImage(named: "no found")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //delegate method
        textField.resignFirstResponder()
        let isbn = txtfISBN.text
        if isbn!.characters.count > 0 {
            var url = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
            url = "\(url)\(isbn!)"
            resetElements()
            requestServer(url)
        }else {
            showAlertMessage("Warning", message: "You must enter the ISBN of the book", owner: self)
        }
        return true
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func requestServer(urlReques: String) {
        if isConnectedToNetwork() {
            let urls = urlReques
            let url = NSURL(string: urls)
            let data = NSData(contentsOfURL: url!)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                let dictionary1 = json as! NSDictionary

                let isbn = "ISBN:" + self.txtfISBN.text!
                if dictionary1[isbn] != nil {
                    print("dictionary1[isbn]: \(dictionary1[isbn])")
                    let dictionary2 = dictionary1[isbn] as! NSDictionary
                    
                    let title = dictionary2["title"] as! NSString as String
                    self.lblTitle.text = title
                    
                    let responseData: NSArray = dictionary2.valueForKey("authors") as! NSArray
                    var author = ""
                    for currentAuthor in responseData {
                        let cAuthor: NSDictionary = currentAuthor as!NSDictionary;
                        author +=  cAuthor.valueForKey("name") as! String + " - "
                    }                    
                    self.lblAuthors.text = author
                    
                    let image: String? = dictionary2.valueForKey("cover")?.valueForKey("medium") as? String
                    
                    if image != nil {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            let imageData = NSData(contentsOfURL: NSURL(string:image!)!);
                            dispatch_async(dispatch_get_main_queue(), {
                                self.imgCover.image = UIImage(data: imageData!);
                            });
                        });
                    }else {
                        self.imgCover.image = UIImage(named: "no found")   
                    }

                }else {
                    resetElements()
                    showAlertMessage("Warning", message: "ISBN not found", owner: self)
                }
                
            }catch {
                return
            }
            
        }else {
            showAlertMessage("Error", message: "There are problems connecting to the Internet", owner: self)
        }
    }
    
    func showAlertMessage (title: String, message: String, owner:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func parsingJson () {
        
    }

}

