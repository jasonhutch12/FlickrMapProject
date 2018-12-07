//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Ron Bernaldo on 4/14/18.
//  Copyright (c) 2018 Ron Bernaldo. All rights reserved.
//

import Foundation

class FlickrAPI: NSObject {
    static let sharedInstance = FlickrAPI()    // Create a Singleton for the class
    
    var photos: Array<String> = []
    var errorLevel = 0

    // Flickr Constants
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "cb9b903f0de389b8978250e4a240b11a"
    
    func fetchPhotosFromFlickrBasedOn(Latitude lat: Double, Longitude lng: Double, PageToFetch pageToFetch: Int, completion: @escaping (_ error: Int, _ pg: Int, _ pgs: Int) -> Void) {
        // Empty our Photos Array
        photos.removeAll(keepingCapacity: true)
        
        // Build Aurgument List
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "lat": String(format: "%f", lat),
            "lon": String(format: "%f", lng),
            "accuracy": "15",       // Accuracy (Street Level)
            "radius": "50",          // Distance
            "radius_units": "km",   // in Kilometers,
            "safe_search": "1",     // Safe (G Rated),
            "content_type": "1",    // Photos Only
            "per_page": "100",      // Photos per Page
            "page": "\(pageToFetch)",
            "extras": "url_m",      // Return Photo URLs
            "format": "json",       // Request JSON data format
            "nojsoncallback": "1"   // No JSON Callback
        ]
        
        // Initialize Shared Session
        let session = URLSession.shared
        let url = URL(string: BASE_URL + escapeUrlParameters(methodArguments))!
        let request = URLRequest(url: url)
        var page = 0
        var pages = 0
        
        // Setup Session Handler
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            self.errorLevel = 0  // Initialize Error Level
            if error != nil {
                self.errorLevel = 1  //***** Network Error
            } else {
                // Okay to Parse JSON
                do {
                    let parsedResult: AnyObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    if let photosDictionary = parsedResult.value(forKey: "photos") as? NSDictionary {
                        if let photoArray = photosDictionary.value(forKey: "photo") as? [[String: AnyObject]] {
                            page = photosDictionary["page"] as! Int
                            pages = photosDictionary["pages"] as! Int
                            for photoDictionary in photoArray {
                                if let photoUrl = photoDictionary["url_m"] as? NSString {
                                    let ext = photoUrl.pathExtension
                                    let noExt = photoUrl.deletingPathExtension
                                    let addThumbDesignation = (noExt + "_q_d") as NSString
                                    let thumbUrl = addThumbDesignation.appendingPathExtension(ext)
                                    self.photos.append(thumbUrl!)
                                    print(self.photos.count)
                                } else {
                                    NSLog("***** Could not obtain an Image URL at Index:%d for Owner:%@", self.photos.count, photoDictionary["owner"] as! String)
                                }
                            }
                        } else {
                            self.errorLevel = 4  //***** No "Photo" Array key present
                        }
                    } else {
                        self.errorLevel = 3  //***** No "Photos" Dictionary key present
                    }
                } catch {
                    self.errorLevel = 2  //***** Parsing Error
                }
                completion(self.errorLevel, page, pages)
            }
        }) 
        task.resume()
    }
    
    // Escape URL Parameters
    func escapeUrlParameters(_ parms: [String : String]) -> String {
        var urlParms = [String]()
        for (key, value) in parms {
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlParms += [key + "=" + "\(escapedValue!)"]
        }
        return urlParms.isEmpty ? "" : "?" + urlParms.joined(separator: "&")
    }
}
