//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 10/04/21.
//

import Foundation

import UIKit
import CoreData
import MapKit


class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var dataController: DataController!
    var photos: [Photo]!


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        collectionView.layoutMargins = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 0)

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.layer.borderWidth = 1


        let space:CGFloat = 2.0
        let widthDimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: widthDimension, height: widthDimension)
        
        
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.black

        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        if photos.isEmpty {
            downloadPhotoData()
        } else {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    // Setting up fetched results controller
       fileprivate func setupFetchedResultsController() {
           let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
          
        
           if let pin = pin {
               let predicate = NSPredicate(format: "pin == %@", pin)
               fetchRequest.predicate = predicate
            
               print("\(pin.latitude) \(pin.longitude)")
           }
           let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
           fetchRequest.sortDescriptors = [sortDescriptor]
           
           fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: dataController.viewContext,
                                                                 sectionNameKeyPath: nil, cacheName: "photo")

           do {
               try fetchedResultsController.performFetch()
           } catch {
               fatalError("The fetch could not be performed: \(error.localizedDescription)")
           }
       }

    @IBAction func newCollection(_ sender: Any) {

        print(dataController.viewContext.hasChanges)
        try? self.dataController.viewContext.save()
        collectionView.reloadData()
        photos.removeAll()
        downloadPhotoData()
    }

    
    
    func downloadPhotoData() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let pagesCount = Int(self.pin.pages)
        FlickrApiCall.getPhotos(latitude: pin.latitude,longitude: pin.longitude,
                               totalPageAmount: pagesCount) { (photos, totalPages, error) in
            
        if photos.count > 0 {
            DispatchQueue.main.async {
                if (pagesCount == 0) {
                    self.pin.pages = Int32(Int(totalPages))
                }
                for photo in photos {
                    print("phots  \(photo.url_m)")
                    let imageURL = URL(string: photo.url_m)
                    
                    guard let imageData = try? Data(contentsOf: imageURL!) else {
                        print("Image does not exist at \(String(describing: imageURL))")
                        return
                    }
                    
                    
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.imageUrl = URL(string: photo.url_m)
                    newPhoto.imageData = imageData
                    newPhoto.pin = self.pin
                    newPhoto.imageID = UUID().uuidString
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                    
                    try? self.dataController.viewContext.save()
                    self.photos.append(newPhoto)
                    
                 
           
                }
                
            }
        }
      }

    }

    
    @IBAction func onClickDelete(_ sender: Any) {
       removeSelectedImages()
    }
    

    @IBAction func onClickDone(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func removeSelectedImages() {
      var imageIds: [String] = []
           
        if let selectedImagesIndexPaths = collectionView.indexPathsForSelectedItems {
               for indexPath in selectedImagesIndexPaths {
                   let selectedImageToRemove = fetchedResultsController.object(at: indexPath)
                   
                if let imageId = selectedImageToRemove.imageID {
                       imageIds.append(imageId)
                   }
               }
               
               for imageId in imageIds {
                   if let selectedImages = fetchedResultsController.fetchedObjects {
                       for image in selectedImages {
                           if image.imageID == imageId {
                                print("Removed")
                            
                               dataController.viewContext.delete(image)
                            showAlert(message: "Successfully deleted", title: "Photo removed", handler: { (action: UIAlertAction!) in
                                    self.navigationController?.popViewController(animated: true)
                            })
                            
                         self.navigationController?.popViewController(animated: true)
                           } else {
                            print("Unable to remove the photo")
                            showAlert(message: "Failed to delete", title: "Photo not removed", handler: { (action: UIAlertAction!) in
                                    self.navigationController?.popViewController(animated: true)
                            })
                   
                            
                         self.navigationController?.popViewController(animated: true)
                       
                           }
                           do {
                               try dataController.viewContext.save()
                           } catch {
                           }
                       }
                   }
               }
           }
        var message = "Please, tap in one photo to remove"
        if(imageIds.isEmpty){
            message = "No photos found, try a new collection or choose another place"
        }
        
        showAlert(message: message, title: "Failed to delete", handler: nil)
    

    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
       
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
           let reuseId = "pin"
           var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
       

           if pinView == nil {
               pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
               pinView!.canShowCallout = false
               pinView!.pinTintColor = .red
            
           } else {
               pinView!.annotation = annotation
           }
           
           pinView?.isSelected = true
           pinView?.isUserInteractionEnabled = false
           return pinView
       }
    
    func setUpMapView() {
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta:  0.015, longitudeDelta: 0.015)
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(AnnotationPin(pin: pin))
    }
    
}



