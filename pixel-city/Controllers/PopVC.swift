//
//  Created by ViXette on 16/02/2018.
//

import UIKit


class PopVC: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var popImage: UIImageView!
	
	var passedImage: UIImage!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		popImage.image = passedImage
		
		addDoubleTapGestureRecognizer()
	}
	
	
	func initData (forImage image: UIImage) {
		passedImage = image
	}
	
	
	func addDoubleTapGestureRecognizer () {
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		doubleTapGestureRecognizer.delegate = self
		
		view.addGestureRecognizer(doubleTapGestureRecognizer)
	}
	
	
	@objc func close () {
		dismiss(animated: true, completion: nil)
	}
	
}
