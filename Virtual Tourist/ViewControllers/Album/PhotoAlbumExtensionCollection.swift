//
//  PhotoAlbumExtensionCollection.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 13/04/21.
//

import Foundation
import UIKit
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
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
        print("collectionView count")
        print(photos.count)

        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("collectionView ")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
        print(photos.count)
        cell.photoImageView.image = UIImage(data: self.photos[indexPath.row].imageData!)
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 1.0
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let cellsAcross: CGFloat = 1
//        let spaceBetweenCells: CGFloat = 0
//        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
//        return CGSize(width: dim, height: dim)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        dataController.viewContext.delete(photos[indexPath.row])
        try? self.dataController.viewContext.save()
        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let bounds = collectionView.bounds
//
//        return CGSize(width: (bounds.width/2)-4, height: bounds.height/2)
//
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top:2, left:2, bottom:2, right:2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
        
    }
    
}
