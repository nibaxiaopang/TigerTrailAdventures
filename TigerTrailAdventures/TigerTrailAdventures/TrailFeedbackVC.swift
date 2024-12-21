//
//  FeedbackVC.swift
//  TigerTrail Adventures
//
//  Created by TigerTrail Adventures on 2024/12/21.
//


import UIKit

class TrailFeedbackVC: UIViewController {
    
    @IBOutlet weak var btnOneStar: UIButton!
    @IBOutlet weak var btnFourStar: UIButton!
    @IBOutlet weak var btnTwoStar: UIButton!
    @IBOutlet weak var btnThreeStar: UIButton!
    @IBOutlet weak var btnFiveStar: UIButton!
    @IBOutlet weak var imgOne: UIImageView!
    @IBOutlet weak var imgTwo: UIImageView!
    @IBOutlet weak var imgTwo2: UIImageView!
    @IBOutlet weak var imgThree: UIImageView!
    @IBOutlet weak var imgThree2: UIImageView!
    @IBOutlet weak var imgThree3: UIImageView!
    @IBOutlet weak var imgFour: UIImageView!
    @IBOutlet weak var imgFour2: UIImageView!
    @IBOutlet weak var imgFour3: UIImageView!
    @IBOutlet weak var imgFour4: UIImageView!
    @IBOutlet weak var imgFive: UIImageView!
    @IBOutlet weak var imgFive2: UIImageView!
    @IBOutlet weak var imgFive3: UIImageView!
    @IBOutlet weak var imgFive4: UIImageView!
    @IBOutlet weak var imgFive5: UIImageView!
    
    //MARK: - Declare Variable
    private var selectedStarRating = 0
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        resetStars()
        navigationController?.navigationBar.isHidden = false
       // navigationItem.title = "Feedback"
    }
    
    //MARK: - Funcions
    private func resetStars() {
        let emptyStarImage = UIImage(named: "emptyStar")
        imgOne.image = emptyStarImage
        imgTwo.image = emptyStarImage
        imgTwo2.image = emptyStarImage
        imgThree.image = emptyStarImage
        imgThree2.image = emptyStarImage
        imgThree3.image = emptyStarImage
        imgFour.image = emptyStarImage
        imgFour2.image = emptyStarImage
        imgFour3.image = emptyStarImage
        imgFour4.image = emptyStarImage
        imgFive.image = emptyStarImage
        imgFive2.image = emptyStarImage
        imgFive3.image = emptyStarImage
        imgFive4.image = emptyStarImage
        imgFive5.image = emptyStarImage
    }
    
    private func fillStars(upTo starNumber: Int) {
        resetStars() // First, reset all stars to empty
        let filledStarImage = UIImage(named: "filledStar")
        selectedStarRating = starNumber
        
        
        switch starNumber {
        case 1:
            imgOne.image = filledStarImage
        case 2:
            [imgTwo2, imgTwo].forEach { $0?.image = filledStarImage }
        case 3:
            [imgThree,imgThree2,imgThree3].forEach { $0?.image = filledStarImage }
        case 4:
            [imgFour,imgFour2,imgFour3,imgFour4].forEach { $0?.image = filledStarImage }
        case 5:
            [imgFive,imgFive2,imgFive3,imgFive4,imgFive5].forEach { $0?.image = filledStarImage }
        default:
            resetStars()
            break
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Declare IBAction
    @IBAction func oneStarTapped(_ sender: UIButton) {
        fillStars(upTo: 1)
    }
    
    @IBAction func twoStarsTapped(_ sender: UIButton) {
        fillStars(upTo: 2)
    }
    
    @IBAction func threeStarsTapped(_ sender: UIButton) {
        fillStars(upTo: 3)
    }
    
    @IBAction func fourStarsTapped(_ sender: UIButton) {
        fillStars(upTo: 4)
    }
    
    @IBAction func fiveStarsTapped(_ sender: UIButton) {
        fillStars(upTo: 5)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        if selectedStarRating == 0 {
           alert(title: "Error", message: "Star is empty, please give rating to select star..!")
        } else {
            alert(title: "Rating", message: "Thank you for give your rate..!")
            selectedStarRating = 0
        }
        resetStars()
        
    }
    func alert(title t:String, message m:String){
        let alert = UIAlertController(title: t, message: m, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
           
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
