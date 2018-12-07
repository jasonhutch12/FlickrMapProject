//
//  ViewController.swift
//  FlickrFinal
//
//  Created by student on 11/8/18.
//  Copyright © 2018 Richland College. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UIKit.UIGestureRecognizerSubclass

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    let locationManager = CLLocationManager()
    let flickr = FlickrAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.Map.showsUserLocation = true
        
        var uilgr = UILongPressGestureRecognizer()
        uilgr.minimumPressDuration = 2.0
        
        Map.addGestureRecognizer(uilgr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func addPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        var touchPoint = gestureRecognizer.location(in: Map)
        var newCoordinates = Map.convert(touchPoint, toCoordinateFrom: Map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        Map.addAnnotation(annotation)
        
        flickr.errorLevel = 0
        flickr.fetchPhotosFromFlickrBasedOn(Latitude: annotation.coordinate.latitude, Longitude: annotation.coordinate.longitude, PageToFetch: 1, completion: {error,pg,pgs in
            print("Error: \(error)")
            print("Page: \(pg)")
            print("Pages: \(pgs)")
            
            
            
        })
        
        print(flickr.photos.count)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.Map.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors " + error.localizedDescription)
    }
}

