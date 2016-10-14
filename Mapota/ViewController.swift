//
//  ViewController.swift
//  Mapota
//
//  Created by Nguyen Duy Khanh on 10/10/16.
//  Copyright © 2016 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var startPointButton: UIButton!
    @IBOutlet weak var endPointButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    var checkPoint : Bool?
    var firstAnotation = MKPointAnnotation()
    var secondAnotation = MKPointAnnotation()
    var firstPlaceMark : MKPlacemark?
    var secondPlaceMark : MKPlacemark?
    
    @IBOutlet weak var vehicleSegment: UISegmentedControl!
    @IBOutlet weak var searchView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        navigationController?.navigationBar.isHidden = false
        customizingSearchView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Update Location
    }
    
    @IBAction func startPointAction(_ sender: AnyObject) {
        print("Push to search Controller")
        checkPoint = true
        pushToSearchBarController(checkPoint: checkPoint!)
    }
    
    @IBAction func endPointAction(_ sender: AnyObject) {
        print("Push to search Controller")
        checkPoint = false
        pushToSearchBarController(checkPoint: checkPoint!)
    }
    
    func pushToSearchBarController(checkPoint : Bool) {
        let searchBarController = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchController
        searchBarController.region = mapView.region
        searchBarController.checkPoint = checkPoint
        searchBarController.searchDelegate = self
        navigationController?.pushViewController(searchBarController, animated: true)
    }
    
    //Update vi tri
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        let region = MKCoordinateRegion(center: (currentLocation?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func getDirection(_ sender: AnyObject) {
        print(firstAnotation.coordinate, secondAnotation.coordinate)
        getDirection()
    }
    
    func getDirection() {
        mapView.showsUserLocation = false
        let sourceMap = MKMapItem(placemark: MKPlacemark(coordinate: firstAnotation.coordinate, addressDictionary: nil))
        let destionationMap = MKMapItem(placemark: MKPlacemark(coordinate: secondAnotation.coordinate, addressDictionary: nil))
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMap
        directionRequest.destination = destionationMap
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                    let alertController = UIAlertController(title: "Mapota", message:
                        "Sorry, we can't found the way", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.overlays.forEach {
                if !($0 is MKUserLocation) {
                    self.mapView.remove($0)
                }
            }
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    @IBAction func segmentIndexChanged(_ sender: AnyObject) {
        switch vehicleSegment.selectedSegmentIndex
        {
        case 0:
            getDirection()
        case 1:
            print("Travel by bus")
        case 2:
            print("Travel by walk")
        case 3:
            print("Travel by bike")
        default:
            break;
        }
    }
    
    @IBAction func showLocation(_ sender: AnyObject) {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        let currentLocation = locationManager.location?.coordinate
        let annotation = CustomAnnotation(title: "Khanh's House", subtitle: "Vinh Tuy, Ha Noi", coordinate: CLLocationCoordinate2D(latitude:(currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!))
        mapView.addAnnotation(annotation)
    }
    
    func customizingSearchView() {
        searchView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        searchView.layer.cornerRadius = 10.0
        searchView.layer.borderColor = UIColor.gray.cgColor
        searchView.layer.borderWidth = 0.5
        searchView.clipsToBounds = true
        startPointButton.titleLabel?.adjustsFontSizeToFitWidth = true
        endPointButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
}

extension ViewController : SearchProtocol{
    func updateAnotation(inputSetButtonTitle : UIButton ,anotation : MKPointAnnotation, mkMapItem : MKMapItem, mkPlaceMark : MKPlacemark){
        
        inputSetButtonTitle.titleLabel?.text = mkMapItem.name
        mapView.removeAnnotation(anotation)
        
        anotation.coordinate = mkPlaceMark.coordinate
        anotation.title = mkPlaceMark.name
        if let city = mkPlaceMark.locality,
            let state = mkPlaceMark.administrativeArea {
            anotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(anotation
        )
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(mkPlaceMark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func mkMapItem(mkMapItem: MKMapItem, checkPoint : Bool) {
        if checkPoint {
            firstPlaceMark = mkMapItem.placemark
            updateAnotation(inputSetButtonTitle: startPointButton,anotation: firstAnotation, mkMapItem: mkMapItem, mkPlaceMark: firstPlaceMark!)
        }else{
            secondPlaceMark = mkMapItem.placemark
            updateAnotation(inputSetButtonTitle: endPointButton,anotation: secondAnotation, mkMapItem: mkMapItem, mkPlaceMark: secondPlaceMark!)
        }
    }
    
}

