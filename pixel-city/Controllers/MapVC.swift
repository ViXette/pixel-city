//
//  Created by ViXette on 01/02/2018.
//

import UIKit
import MapKit


class MapVC: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
	}
	

	@IBAction func centerMapButtonTapped(_ sender: UIButton) {
		
	}

}



extension MapVC: MKMapViewDelegate {
	
}
