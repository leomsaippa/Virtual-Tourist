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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      guard let pin = pin else {
            showAlert(title: "Failed to load photo", message: "Fail to load photo album. Try Again!!")
            fatalError("Error while loading photo album")
        }
        
        navTitle.title = pin.locationName ?? "Album"
        setUpCollectionView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        setupFetchedResultsController()
        downloadPhotoData()
     
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
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    // remove all existing images from current place
    @IBAction func newCollection(_ sender: Any) {
        guard let imageObject = fetchedResultsController.fetchedObjects else { return }
        for image in imageObject {
            dataController.viewContext.delete(image)
           do {
               try dataController.viewContext.save()
           } catch {
                print("Unable to delete images")
            }
        }
        downloadPhotoData()
    }

    
    
    func downloadPhotoData() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        // manage activity indicator : start running
        print("\(String(describing: fetchedResultsController.fetchedObjects?.count))")
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            print("image metadata is already present. no need to re download")
            return
        }

        let pagesCount = Int(self.pin.pages)
        FlickrApiCall.getPhotos(latitude: pin.latitude,longitude: pin.longitude,
                               totalPageAmount: pagesCount) { (photos, totalPages, error) in
            
        if photos.count > 0 {
            DispatchQueue.main.async {
                if (pagesCount == 0) {
                    self.pin.pages = Int32(Int(totalPages))
                }
                for photo in photos {
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.imageUrl = URL(string: photo.url_m)
                    newPhoto.imageData = nil
                    newPhoto.pin = self.pin
                    newPhoto.imageID = UUID().uuidString
                    
                    do {
                        try self.dataController.viewContext.save()
                    } catch {
                        print("Unable to save the photo")
                    }
                }
                
            }
        }
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
      }

    }

    
    @IBAction func onClickDelete(_ sender: Any) {
       removeSelectedImages()
    }
    

    @IBAction func onClickDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
                               dataController.viewContext.delete(image)
                           }
                           do {
                               try dataController.viewContext.save()
                           } catch {
                               print("Unable to remove the photo")
                           }
                       }
                   }
               }
           }
        
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
       
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
            print("images are already present.")
            return cell
        }
    
        // fetch core data
        let photoData = self.fetchedResultsController.object(at: indexPath)

        
        if photoData.imageData == nil {
            // run thread
            newCollectionBtn.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: photoData.imageUrl!) {
                    DispatchQueue.main.async {
                        photoData.imageData = imageData
                        do {
                            try self.dataController.viewContext.save()
                            
                        } catch {
                            print("error in saving image data")
                        }
                        
                        let image = UIImage(data: imageData)!
                        cell.setPhotoImageView(imageView: image, sizeFit: true)
         
                    }
                }
        
            }
            
        } else {
          if let imageData = photoData.imageData {
                let image = UIImage(data: imageData)!
                cell.setPhotoImageView(imageView: image, sizeFit: false)
            }
            
        }
        newCollectionBtn.isEnabled = true
        return cell
    }

    /// Set up the Collection View.
    func setUpCollectionView() {
        // Set up Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        configureFlowLayout()
    }

    /// Set up the flow layout for the Collection View.
    func configureFlowLayout() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
         let space:CGFloat = 3.0
         let dimension = (view.frame.size.width - (2 * space)) / 3.0
         flowLayout.minimumInteritemSpacing = space
         flowLayout.minimumLineSpacing = space
         flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
}



