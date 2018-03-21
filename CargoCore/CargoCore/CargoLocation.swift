//
//  CargoLocation.swift
//  CargoCore
//
//  Created by Julien Gil on 13/03/2018.
//  Copyright © 2018 com.fifty-five. All rights reserved.
//

import Foundation
import CoreLocation

public class CargoLocation : NSObject {

    fileprivate static var location:CLLocation? = nil;

    @objc public static func setLocation(location: CLLocation?) {
        CargoLocation.location = location;
    }
    
    @objc public static func getLocation() -> CLLocation? {
        return CargoLocation.location;
    }
}
