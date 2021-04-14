//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 06/04/21.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!

    let key: String = "persistMapInfo"
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?

    override func viewDidLoad() {
        print("view didLoad")
        super.viewDidLoad()
        mapView.delegate = self
        setupLongPressGesture()
        getPersistInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        refreshData()

    }
    

    func setupLongPressGesture() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        mapView.addGestureRecognizer(longPressGesture)

        
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
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let geoPos = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            let annotation = MKPointAnnotation()
            CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
                guard let placemark = placemarks?.first else { return }
                annotation.title = placemark.name ?? "Unknow"
                annotation.subtitle = placemark.country
                annotation.coordinate = locationCoordinate
                
                let location = Pin(context: self.dataController.viewContext)
                location.creationDate = Date()
                location.longitude = annotation.coordinate.longitude
                location.latitude = annotation.coordinate.latitude
                location.locationName = annotation.title
                location.country = annotation.subtitle
                location.pages = 0
                try? self.dataController.viewContext.save()
                let annotationPin = AnnotationPin(pin: location)
                self.mapView.addAnnotation(annotationPin)
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                //Zoom to 400/400
                self.mapView.setRegion(MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 400, longitudinalMeters: 400), animated: true)
                
            }
            print(locationCoordinate)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
        let pinAnnotation: AnnotationPin = sender as! AnnotationPin
        photoAlbumViewController.pin = pinAnnotation.pin
        photoAlbumViewController.dataController = dataController
    }
    
}


extension MapViewController: MKMapViewDelegate, NSFetchedResultsControllerDelegate {
   
   func refreshData() {
       self.mapView.removeAnnotations(self.mapView.annotations)
       
       let request: NSFetchRequest<Pin> = Pin.fetchRequest()
       let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
       request.sortDescriptors = [sortDescriptor]
          
       dataController.viewContext.perform {
         do {
           let pins = try self.dataController.viewContext.fetch(request)
           self.mapView.addAnnotations(pins.map { pin in AnnotationPin(pin: pin) })
           

           } catch {
               print("Error fetching Pins: \(error)")
           }
       }
       
   }
   
   
   
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       let reuseId = "pin"
       var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
   
       let pinAnnotation = annotation as! AnnotationPin
       pinAnnotation.title = pinAnnotation.pin.locationName
       pinAnnotation.subtitle = pinAnnotation.pin.country
   
       print("\(String(describing: pinAnnotation.title)) \(String(describing: pinAnnotation.subtitle))")
  
       if pinView == nil {
           pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
           pinView!.canShowCallout = true
           pinView!.pinTintColor = .red
           pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
       } else {
           pinView!.annotation = annotation
       }
       
       return pinView
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

   func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
       self.saveMapLocation()
   }

   
   func callPersistedLocation() {
       if let mapRegin = UserDefaults.standard.dictionary(forKey: key) {
           let location = mapRegin as! [String: CLLocationDegrees]
           let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
           let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
           
           mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
       } else{
           print("nothing")
       }
   
   }

   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

       print("mapView go new")
       mapView.deselectAnnotation(view.annotation, animated: false)
       guard let _ = view.annotation else {
               return
           }
       if let annotation = view.annotation as? MKPointAnnotation {
           do {
               let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
               let pindata = try dataController.fetchLocation(predicate)!
               let annotationPin = AnnotationPin(pin: pindata)
               self.performSegue(withIdentifier: "showAlbum", sender: annotationPin)
           } catch {
               print("Something went wrong")
           }
       }
       
   }
 
}
