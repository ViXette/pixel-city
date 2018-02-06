//
//  Created by ViXette on 06/02/2018.
//

import UIKit
import MapKit


class DroppablePin: NSObject, MKAnnotation {
	
	dynamic var coordinate: CLLocationCoordinate2D
	var id: String
	
	init (coordinate: CLLocationCoordinate2D, id: String) {
		self.coordinate = coordinate
		self.id = id
		
		super.init()
	}
	
}
