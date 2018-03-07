//
//  ViewController.swift
//  TestApp
//
//  Created by Julien Gil on 13/02/2018.
//  Copyright © 2018 com.fifty-five. All rights reserved.
//

import UIKit
import CargoCore

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!;
    
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userEmailText: UITextField!
    @IBOutlet weak var event_screenText: UITextField!
    
    @IBOutlet weak var xboxText: UITextField!
    @IBOutlet weak var playstationText: UITextField!
    @IBOutlet weak var nintendoText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        Analytics.logEvent("applicationStart", parameters: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedEvent(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        parameters["eventName"] = "Cargo Event";
        
        if let eventName = self.event_screenText.text {
            parameters["eventName"] = eventName;
            self.event_screenText.text = nil;
        }
        Analytics.logEvent("tagEvent", parameters: parameters);
    }
    
    
    @IBAction func pressedUser(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        
        if let username = self.userNameText.text {
            parameters["userName"] = username;
        }
        if let userEmail = self.userEmailText.text {
            parameters["userEmail"] = userEmail;
        }
        
        Analytics.logEvent("tagUser", parameters: parameters as [String : NSObject]?);
    }
    
    @IBAction func pressedScreen(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        parameters["screenName"] = "Main Screen";
        
        if let screenName = self.event_screenText.text {
            parameters["screenName"] = screenName;
            self.event_screenText.text = nil;
        }
        Analytics.logEvent("tagScreen", parameters: parameters);
    }
    
    @IBAction func pressedPurchase(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        var revenue: CGFloat = 0;
        parameters["currencyCode"] = "EUR";
        
        if let qty = self.xboxText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let xbox = CargoItem.init(name: "xBox One", unitPrice: 149.99, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: xbox);
                revenue += xbox.revenue;
            }
        }
        if let qty = self.playstationText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let playstation = CargoItem.init(name: "Playstation 4", unitPrice: 240.75, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: playstation);
                revenue += playstation.revenue;
            }
        }
        if let qty = self.nintendoText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let nintendo = CargoItem.init(name: "Nintendo Switch", unitPrice: 350, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: nintendo);
                revenue += nintendo.revenue;
            }
        }
        parameters["totalRevenue"] = revenue;
        if (CargoItem.getItemsArray().count != 0) {
            parameters["eventItems"] = true;
        }
        Analytics.logEvent("tagPurchase", parameters: parameters as [String : NSObject]?);
    }
    
    @IBAction func clickOnView(_ sender: UITapGestureRecognizer) {
        dismissKeyboard();
    }
    
    func dismissKeyboard() {
        userNameText.resignFirstResponder();
        userEmailText.resignFirstResponder();
        event_screenText.resignFirstResponder();
        xboxText.resignFirstResponder();
        playstationText.resignFirstResponder();
        nintendoText.resignFirstResponder();
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollPoint = CGPoint(x:0, y:textField.frame.origin.y/2);
        scrollView.setContentOffset(scrollPoint, animated: true);
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint.zero, animated: true);
    }
    
    
    
}

