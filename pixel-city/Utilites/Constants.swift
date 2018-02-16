//
//  Created by ViXette on 13/02/2018.
//

import Foundation


let API_KEY = "b2ea835fbeef221da9cc08e34afc5b81"

let numberOfPhotos = 40


func makeFlickrUrl (forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos photos: Int) -> String {
	return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(photos)&format=json&nojsoncallback=1"
}
