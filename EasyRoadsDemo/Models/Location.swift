//
//  Location.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import GoogleMaps
import GooglePlaces

class Location: NSObject {
    
    var placeLocation: CLLocation!
    var marker: GMSMarker!
    var polyLine: GMSPolyline?
    
    init(withLocation placeLocation: CLLocation, mapMarker marker: GMSMarker) {
        super.init()
        self.placeLocation = placeLocation
        self.marker = marker
    }

}
