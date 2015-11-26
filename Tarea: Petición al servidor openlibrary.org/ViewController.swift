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
    @IBOutlet weak var txtvResult: UITextView!
    
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //delegate method
        textField.resignFirstResponder()
        let isbn = txtfISBN.text
        if isbn!.characters.count > 0 {
            var url = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
            url = "\(url)\(isbn!)"
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
            let datos:NSData? = NSData(contentsOfURL: url!)
            let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            self.txtvResult.text = texto! as String
        }else {
            showAlertMessage("Error", message: "There are problems connecting to the Internet", owner: self)
        }
    }
    
    @IBAction func btnClear(sender: AnyObject) {
        txtvResult.text = ""
        txtfISBN.text = ""
    }
    
    func showAlertMessage (title: String, message: String, owner:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

