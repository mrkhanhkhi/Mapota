//
//  CustomAnnotation.swift
//  Mapota
//
//  Created by Nguyen Duy Khanh on 10/10/16.
//  Copyright © 2016 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
//    var image: UIImage?
    
    init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
