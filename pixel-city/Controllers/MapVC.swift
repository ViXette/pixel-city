//
//  Created by ViXette on 01/02/2018.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage


class MapVC: UIViewController, UIGestureRecognizerDelegate {

	let locationManager = CLLocationManager()
	let authStatus = CLLocationManager.authorizationStatus()
	let regionRadius = 1000.0
	var imageUrls = [String]()
	var images = [UIImage]()
	
	var spinner: UIActivityIndicatorView?
	var progress_label: UILabel?
	var collectionViewFlowLayout = UICollectionViewFlowLayout()
	var collectionView: UICollectionView?
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var pullUpView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		
		configureLocationServices()
		
		mapView.delegate = self
		
		addDoubleTapGestureRecognizer()
		
		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewFlowLayout)
		collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
		collectionView?.delegate = self
		collectionView?.dataSource = self
		collectionView?.backgroundColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
		
		registerForPreviewing(with: self, sourceView: collectionView!)
		
		pullUpView.addSubview(collectionView!)
	}
	
	
	func addDoubleTapGestureRecognizer () {
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		doubleTapGestureRecognizer.delegate = self
		
		mapView.addGestureRecognizer(doubleTapGestureRecognizer)
	}
	
	
	func addSwipeGestureResognizer () {
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
		swipeGestureRecognizer.direction = .down
		
		pullUpView.addGestureRecognizer(swipeGestureRecognizer)
	}
	
	
	func animateViewUp () {
		mapViewBottomConstraint.constant = 300
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	@objc func animateViewDown () {
		cancelAllSessions()
		
		mapViewBottomConstraint.constant = 0
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	func addSpinner () {
		removeSpinner()
		
		spinner = UIActivityIndicatorView()
		spinner?.center = CGPoint(
			x: (UIScreen.main.bounds.width / 2) - ((spinner?.frame.width)! / 2),
			y: (pullUpView.bounds.height / 2) - ((spinner?.frame.height)! / 2)
		)
		spinner?.activityIndicatorViewStyle = .whiteLarge
		spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

		spinner?.startAnimating()

		collectionView?.addSubview(spinner!)
	}
	
	
	func removeSpinner () {
		if spinner != nil {
			spinner?.removeFromSuperview()
		}
	}
	
	
	func addProgressLabel () {
		removeProgressLabel()
		
		progress_label = UILabel()
		
		let labelWidth: CGFloat = 250
		
		progress_label?.frame = CGRect(
			x: (UIScreen.main.bounds.width / 2) - (labelWidth / 2),
			y: pullUpView.bounds.height / 4 * 3,
			width: labelWidth,
			height: 40
		)
		progress_label?.font = UIFont(name: "Avenir Next", size: 18)
		progress_label?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		progress_label?.textAlignment = .center
		
		collectionView?.addSubview(progress_label!)
	}
	
	
	func removeProgressLabel () {
		if progress_label != nil {
			progress_label?.removeFromSuperview()
		}
	}
	
	
	@IBAction func centerMapButtonTapped(_ sender: UIButton) {
		if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
			centerMapOnUserLocation()
		}
	}
	
	
	func retrieveUrls (forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
		Alamofire.request(makeFlickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: numberOfPhotos))
			.responseJSON {
				response in
				
				guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }

				let photosDictionary = json["photos"] as! Dictionary<String, AnyObject>
				let photos = photosDictionary["photo"] as! [Dictionary<String, AnyObject>]

				for photo in photos {
					let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"

					self.imageUrls.append(postUrl)
				}

				handler(true)
			}
	}
	
	
	func retrieveImages (handler: @escaping (_ status: Bool) -> ()) {
		for url in imageUrls {
			Alamofire.request(url).responseImage(completionHandler: {
				response in
				
				guard let image = response.result.value else { return }
				
				self.images.append(image)
				
				self.progress_label?.text = "\(self.images.count)/\(numberOfPhotos) Images downloaded"
				
				if self.images.count == self.imageUrls.count {
					handler(true)
				}
			})
		}
	}
	

	func cancelAllSessions () {
		Alamofire.SessionManager.default.session.getTasksWithCompletionHandler {
			sessionDataTask, uploadDataTask, downloadDataTask in
			
			sessionDataTask.forEach({ $0.cancel() })
			
			downloadDataTask.forEach({ $0.cancel() })
		}
	}

}



extension MapVC: CLLocationManagerDelegate {
	
	func configureLocationServices () {
		if authStatus == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		}
	}
	
}



extension MapVC: MKMapViewDelegate {
	
	func centerMapOnUserLocation () {
		guard let coordinate = locationManager.location?.coordinate else { return }
		
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
		
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		centerMapOnUserLocation()
	}
	
	
	@objc func dropPin (sender: UITapGestureRecognizer) {
		cancelAllSessions()
		
		images = []
		imageUrls = []
		collectionView?.reloadData()
		
		let touchPoint = sender.location(in: mapView)
		let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		
		let annotation = DroppablePin(coordinate: touchCoordinate, id: "droppablePin")
		
		mapView.removeAnnotations(mapView.annotations)
		mapView.addAnnotation(annotation)
		
		animateViewUp()
		addSwipeGestureResognizer()
		addSpinner()
		addProgressLabel()
		
		mapView.setRegion(MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius), animated: true)
		
		retrieveUrls(forAnnotation: annotation) {
			finished in
			
			if finished {
				self.retrieveImages {
					finished in
					
					if finished {
						self.removeSpinner()
						self.removeProgressLabel()

						self.collectionView?.reloadData()
					}
				}
			}
		}
	}
	
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		
		let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
		pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
		pinAnnotation.animatesDrop = true
		
		return pinAnnotation
	}
	
}



extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
			else { return UICollectionViewCell() }
		
		let imageView = UIImageView(image: images[indexPath.row])
		
		cell.addSubview(imageView)
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC
			else { return }
		
		popVC.initData(forImage: images[indexPath.row])
		
		present(popVC, animated: true, completion: nil)
	}
	
}



extension MapVC: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
		
		guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }
		
		popVC.initData(forImage: images[indexPath.row])
		
		previewingContext.sourceRect = cell.contentView.frame
		return popVC
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		show(viewControllerToCommit, sender: self)
	}
}
