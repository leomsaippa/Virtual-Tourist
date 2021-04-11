//
//  FlickrApiCall.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 09/04/21.
//


import Foundation
import UIKit

class FlickrApiCall{
    
    //TODO: ADD YOUR API KEY AND KEY SECRET HERE
    static let apiKey = "YOUR API KEY"
    static let keySecret = "YOUR KEY SECRET"
    
    enum Endpoints {
           static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
           static let radius = 20
           case searchURLString(Double, Double, Int, Int)

           var urlString: String {
               switch self {
                    case .searchURLString(let latitude, let longitude, let perPage, let pageNum):
                      return Endpoints.base + "&api_key=\(FlickrApiCall.apiKey)" +
                            "&lat=\(latitude)" +
                            "&lon=\(longitude)" +
                            "&radius=\(Endpoints.radius)" +
                            "&per_page=\(perPage)" +
                            "&page=\(pageNum)" +
                        "&format=json&nojsoncallback=1&extras=url_m"
               }
               
           }
        
         var url: URL {
               return URL(string: urlString)!
           }
      }
        
    class func getRandomPageNumber(totalPicsAvailable: Int, maxNumPicsdisplayed: Int) -> Int {
        let flickrLimit = 4000
        // Available total number of pics or flickr limit
        let numberPages = min(totalPicsAvailable, flickrLimit) / maxNumPicsdisplayed
        let randomPageNum = Int.random(in: 0...numberPages)
        print("totalPicsAvaible is \(totalPicsAvailable), numPage is \(numberPages)",
             "randomPageNum is \(randomPageNum)" )
        
        return randomPageNum
    }
    
    class func getFlickrURL(latitude: Double, longitude: Double, totalPageAmount: Int = 0, picsPerPage: Int = 15) -> URL {
        
       let perPage = picsPerPage
       let pageNum = getRandomPageNumber(totalPicsAvailable: totalPageAmount, maxNumPicsdisplayed: picsPerPage)
       let searchURL = Endpoints.searchURLString(latitude, longitude, perPage, pageNum).url
    
        print("\n searchURL")
        return searchURL
        
    }
    
    class func getPhotos(latitude: Double, longitude: Double, totalPageAmount:  Int = 0, completion: @escaping ([Photo], Int, Error?) -> Void) -> Void {
           let url = getFlickrURL(latitude: latitude, longitude: longitude, totalPageAmount: totalPageAmount)
        let _ = RequestHelper.taskForGETRequest(url: url, responseType: PhotoResponse.self) { response, error in
               if let response = response {
                completion(response.photos.photo, response.photos.pages, nil)
               } else {
                   completion([], 0, error)
               }
           }
       }
    
    class func downloadImage(img: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: img)
        
        guard let imageURL = url else {
             DispatchQueue.main.async {
                 completion(nil, nil)
             }
             return
         }
         
         let request = URLRequest(url: imageURL)
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             DispatchQueue.main.async {
                 completion(data, nil)
             }
         }
         task.resume()
    }
}
