//
//  ViewController.swift
//  TestApp
//
//  Created by Julien Gil on 13/02/2018.
//  Copyright © 2018 com.fifty-five. All rights reserved.
//

import UIKit
import CargoCore
import CoreLocation

@available(iOS 9.0, *)
class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!;

    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userEmailText: UITextField!
    @IBOutlet weak var event_screenText: UITextField!

    @IBOutlet weak var xboxText: UITextField!
    @IBOutlet weak var playstationText: UITextField!
    @IBOutlet weak var nintendoText: UITextField!
    
    @IBOutlet weak var privacyStatusSegment: UISegmentedControl!
    
    let locationManager = CLLocationManager();
    @IBOutlet weak var sendLocation: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization();
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization();

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        }
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
        
        if (sendLocation.isOn) {
            Analytics.logEvent("tagLocation", parameters: nil);
        }
    }

    @IBAction func afterEditXBox(_ sender: UITextField) {
        Analytics.logEvent("actionStart", parameters: ["actionName": "shopXbox"]);
    }
    @IBAction func afterEditPlaystation(_ sender: UITextField) {
        Analytics.logEvent("actionStart", parameters: ["actionName": "shopPlaystation"]);
    }
    @IBAction func afterEditNintendo(_ sender: UITextField) {
        Analytics.logEvent("actionStart", parameters: ["actionName": "shopNintendo"]);
    }

    @IBAction func pressedUser(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        
        if let username = self.userNameText.text {
            parameters["userName"] = username;
            self.userNameText.text = nil;
        }
        if let userEmail = self.userEmailText.text {
            parameters["userEmail"] = userEmail;
            self.userEmailText.text = nil;
        }
        Analytics.logEvent("tagUser", parameters: parameters as [String : NSObject]?);

        if (sendLocation.isOn) {
            Analytics.logEvent("tagLocation", parameters: nil);
        }
    }
    
    @IBAction func pressedScreen(_ sender : AnyObject) {
        var parameters = [String: AnyHashable]();
        parameters["screenName"] = "Main Screen";
        
        if let screenName = self.event_screenText.text {
            parameters["screenName"] = screenName;
            self.event_screenText.text = nil;
        }
        Analytics.logEvent("tagScreen", parameters: parameters);
        if (sendLocation.isOn) {
            Analytics.logEvent("tagLocation", parameters: nil);
        }
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
                self.xboxText.text = nil;
                Analytics.logEvent("actionEnd", parameters: ["actionName": "shopXbox", "successfulAction": true]);
            }
        }
        if let qty = self.playstationText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let playstation = CargoItem.init(name: "Playstation 4", unitPrice: 240.75, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: playstation);
                revenue += playstation.revenue;
                self.playstationText.text = nil;
                Analytics.logEvent("actionEnd", parameters: ["actionName": "shopPlaystation", "successfulAction": true]);
            }
        }
        if let qty = self.nintendoText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let nintendo = CargoItem.init(name: "Nintendo Switch", unitPrice: 350, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: nintendo);
                revenue += nintendo.revenue;
                self.nintendoText.text = nil;
                Analytics.logEvent("actionEnd", parameters: ["actionName": "shopNintendo", "successfulAction": true]);
            }
        }
        parameters["totalRevenue"] = revenue;
        if (CargoItem.getItemsArray().count != 0) {
            parameters["eventItems"] = true;
        }
        Analytics.logEvent("tagPurchase", parameters: parameters as [String : NSObject]?);
        if (sendLocation.isOn) {
            Analytics.logEvent("tagLocation", parameters: nil);
        }
    }

    @IBAction func switchLocationValueChanged(_ sender: UISwitch) {
        if (sendLocation.isOn) {
            locationManager.startUpdatingLocation();
        }
        else {
            locationManager.stopUpdatingLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else {
            return;
        }
        CargoLocation.setLocation(location: locValue);
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    @IBAction func PrivacyStatusSegmentValueChanged(_ sender: UISegmentedControl) {
        var privacyStatus = "UNKNOWN";

        if (privacyStatusSegment.selectedSegmentIndex == 0) {
            privacyStatus = "OPT_IN";
        }
        else if (privacyStatusSegment.selectedSegmentIndex == 1) {
            privacyStatus = "OPT_OUT";
        }
        else {
            privacyStatus = "UNKNOWN";
        }
        Analytics.logEvent("setPrivacy", parameters: ["privacyStatus" : privacyStatus]);
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

