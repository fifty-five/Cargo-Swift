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

    fileprivate var location:CLLocation? = nil;

    public func setLocation(location: CLLocation) {
        self.location = location;
    }
    
    public func getLocation() -> CLLocation {
        return self.location!;
    }
}
