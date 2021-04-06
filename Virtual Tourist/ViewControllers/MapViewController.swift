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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLongPressGesture()
    }
    
    func setupLongPressGesture() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        mapView.addGestureRecognizer(longPressGesture)

        
    }


    @objc func onLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
            print("onLongPress")
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
