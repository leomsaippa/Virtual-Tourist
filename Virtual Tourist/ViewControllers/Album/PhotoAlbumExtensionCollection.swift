//
//  PhotoAlbumExtensionCollection.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 13/04/21.
//

import Foundation
import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
      guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
          return cell
      }
  
      let photoData = self.fetchedResultsController.object(at: indexPath)

      
      if photoData.imageData == nil {
          DispatchQueue.global(qos: .background).async {
              if let imageData = try? Data(contentsOf: photoData.imageUrl!) {
                  DispatchQueue.main.async {
                      photoData.imageData = imageData
                      do {
                          try self.dataController.viewContext.save()
                          
                      } catch {
                        print("Error retrieving data ")
                      }
                      
                      let image = UIImage(data: imageData)!
                    cell.photoImageView.image = image
       
                  }
              }
      
          }
          
      } else {
        if let imageData = photoData.imageData {
              let image = UIImage(data: imageData)!
            cell.photoImageView.image = image
          }
          
      }
        
    cell.contentView.layer.borderColor = UIColor.white.cgColor
    cell.contentView.layer.borderWidth = 1.0
    return cell
  }
    

    
}
