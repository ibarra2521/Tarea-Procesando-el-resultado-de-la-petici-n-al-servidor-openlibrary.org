
//
//  ViewController.swift
//  Tarea: Petición al servidor openlibrary.org
//
//  Created by Nivardo Ibarra on 11/25/15.
//  Copyright © 2015 Nivardo Ibarra. All rights reserved.
//

import UIKit

// THREE (3.1)
class ViewController: UIViewController, UITextFieldDelegate, WebserviceHelperDelegate {
    @IBOutlet weak var txtfISBN: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthors: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    // THREE (3.2)
    let connection = WebserviceHelper()
    var books: [Book] = [Book]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtfISBN.delegate = self
        txtfISBN.clearButtonMode = .WhileEditing
        // THREE (3.3)
        self.connection.delegate = self
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
            resetElements()
            requestServer()
        }else {
            showAlertMessage("Warning", message: "You must enter the ISBN of the book", owner: self)
        }
        return true
    }
        
    func requestServer() {
        let reachability = Reachability()
        if reachability.isConnectedToNetwork() {
            // FOUR (4.2)
            self.connection.loadDataFromWebService(self.txtfISBN.text!)
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
    
    // THREE (3.4)
    func webserviceHelper (book: Book) {
        print("book \(book)")
        if book.isbn != "" {
            books.append(book)
            self.lblTitle.text = book.title
            self.lblAuthors.text = book.authors
            
            if book.imageUrl != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let imageData = NSData(contentsOfURL: NSURL(string:book.imageUrl!)!);
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
    }

}

