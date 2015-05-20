//
//  ViewController.swift
//  GPSTrackerSample
//
//  Created by Akihito Ohsato on 2015/05/20.
//  Copyright (c) 2015年 Akihito Ohsato. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let CLOCK_WAIT: Double = 0.10 // [s]
    let DATE_FORMAT: String = "yyyy/MM/dd HH:mm:ss:SSS"
    let DF = NSDateFormatter()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var clockTextView: UITextView!
    @IBOutlet weak var gpsTextView: UITextView!
    @IBOutlet weak var resetButton: UIButton!
    
    var clockTimer : NSTimer!
    var nowDate: NSDate = NSDate()
    var locationManager: CLLocationManager!
    var preLocation: CLLocation!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // setup date formatter
        DF.dateFormat = DATE_FORMAT
        
        // setup clock thread
        clockTimer = NSTimer.scheduledTimerWithTimeInterval(
            CLOCK_WAIT, target: self, selector: "updateClock:", userInfo: nil, repeats: true)
        
        // setup location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        // check & allow location manager
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        // setup map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // logging clock
    func clockLog(text: String) { clockTextView.text = text }
    func clockLog(date: NSDate) { clockLog(date2log(date)) }
    func date2log(date: NSDate) -> String { return ("Clock: " + DF.stringFromDate(date)) }
    
    // logging gps
    func gpsLog(text: String) { gpsTextView.text = text }
    func gpsLog(location: CLLocation) { gpsLog(location2log(location)) }
    
    func location2log(location: CLLocation) -> String {
        
        var str: String = ""
        str += "Timestamp: " + DF.stringFromDate(location.timestamp) + "\n"
        str += "Latitude: " + location.coordinate.latitude.description + " [deg]\n" // Double
        str += "Longitude: " + location.coordinate.longitude.description + " [deg]\n" // Double
        str += "Altitude: " + location.altitude.description + " [m]\n" // Double
        str += "Floor level: " + location.floor.level.description + " [-]\n" // Int
        str += "HorizontalAccuracy: " + location.horizontalAccuracy.description + " [m]\n" // Double
        str += "VerticalAccuracy: " + location.verticalAccuracy.description + " [m]\n" // Double
        str += "Speed: " + location.speed.description + " [m/s]\n" // Double
        str += "Course: " + location.course.description + " [deg]"// Double
//        str += "Timestamp: " + location.timestamp.description + "\n" // NSDate
//        str = location.description // String
        return str
    }
    
    // callback clock
    func updateClock(timer: NSTimer) {
        
        // get new date
        nowDate = NSDate()
        // loggin clock
        clockLog(nowDate)
    }
    
    // callback gps
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation!]) {
        
        // get newest location info
        let newLocation: CLLocation = locations[0]
        
        // update map view
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.005, 0.005))
        mapView.setRegion(newRegion, animated: true)
        
        // draw polyline
        if preLocation != nil {
            var line = [preLocation.coordinate, newLocation.coordinate]
            var polyLine = MKPolyline(coordinates: &line, count: line.count)
            mapView.addOverlay(polyLine)
        }
        
        preLocation = newLocation
        
        // logging gps
        gpsLog(newLocation)
    }
    
    // callback gps error
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {

        // logging gps error
        gpsLog(error.description)
    }
    
    // callback update map
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        
        return nil
    }
    
    // callback reset button
    @IBAction func pushReset(sender: AnyObject) {
        
        // clear all overlay
        for overlay in mapView.overlays { mapView.removeOverlay(overlay as MKOverlay) }
    }
}

