//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 06/04/21.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!

    let key: String = "persistMapInfo"

    override func viewDidLoad() {
        print("view didLoad")
        super.viewDidLoad()
        mapView.delegate = self
        setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        getPersistInfo()

    }
    

    func setupLongPressGesture() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        mapView.addGestureRecognizer(longPressGesture)

        
    }
    
    //Save info when map view change
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print("Saving when map change")
        self.saveMapLocation()
    }
    
    func saveMapLocation() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: key)
        try? dataController.viewContext.save()

    }

    func getPersistInfo() {
        if let mapRegin = UserDefaults.standard.dictionary(forKey: key) {
            let location = mapRegin as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            print("getPersistInfo \(center)")
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        } else{
            print("Failed to let MapRegion")
        }
    }

    @objc func onLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let locationCoordinate = mapView.convert(longPressGestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.title = ""
        annotation.subtitle = ""
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
        //Zoom to 400/400
        mapView.setRegion(MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 400, longitudinalMeters: 400), animated: true)
        
   
        print(locationCoordinate)
    }
        

    
    
    
}
