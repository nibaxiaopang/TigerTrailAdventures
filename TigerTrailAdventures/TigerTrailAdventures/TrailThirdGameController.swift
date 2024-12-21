//
//  ThirdGame.swift
//  TigerTrail Adventures
//
//  Created by TigerTrail Adventures on 2024/12/21.
//


import UIKit

class TrailThirdGameController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var selectedNumberLabel: UILabel!
    
    // MARK: - Properties
    private var numbers: [Int] = []
    private var selectedIndexPath: IndexPath? = nil
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var firstSelectedNumber: Int?
    private var firstSelectedIndexPath: IndexPath?
    private var remainingPairs: Int = 25 // Total cells in 5x5 grid
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        startNewGame()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    @IBAction func btnBack(_ sender : UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    private func startNewGame() {
        generateNumbers()
        score = 0
        remainingPairs = 25
        selectedNumberLabel.text = "Selected Number: None"
        firstSelectedNumber = nil
        firstSelectedIndexPath = nil
        collectionView.reloadData()
    }
    
    private func generateNumbers() {
        numbers = (0..<25).map { _ in Int.random(in: 1...100) }
    }
    
    private func updateUI() {
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    private func shuffleNumbers() {
        numbers.shuffle()
        updateUI()
    }
    
    private func checkForWin() {
        if remainingPairs <= 0 {
            let alert = UIAlertController(title: "Congratulations!", 
                                        message: "You've won! Your score: \(score)", 
                                        preferredStyle: .alert)
            
            let newGameAction = UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
                self?.startNewGame()
            }
            
            alert.addAction(newGameAction)
            present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension TrailThirdGameController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as! NumberCell
        cell.configure(with: numbers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 20) / 5 // 5x5 grid
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedNumber = numbers[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath) as? NumberCell
        
        if let firstNumber = firstSelectedNumber, let firstPath = firstSelectedIndexPath {
            // Second selection
            if firstPath == indexPath {
                // Tapped same cell, deselect it
                cell?.contentView.backgroundColor = .systemBlue
                firstSelectedNumber = nil
                firstSelectedIndexPath = nil
                selectedNumberLabel.text = "Selected Number: None"
                return
            }
            
            if firstNumber == selectedNumber {
                // Match found!
                // Animate and remove both cells
                UIView.animate(withDuration: 0.3) {
                    cell?.contentView.backgroundColor = .green
                    collectionView.cellForItem(at: firstPath)?.contentView.backgroundColor = .green
                } completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        cell?.alpha = 0
                        collectionView.cellForItem(at: firstPath)?.alpha = 0
                    } completion: { _ in
                        // Generate new numbers
                        self.numbers[indexPath.item] = Int.random(in: 1...100)
                        self.numbers[firstPath.item] = Int.random(in: 1...100)
                        
                        // Update UI
                        UIView.animate(withDuration: 0.3) {
                            cell?.alpha = 1
                            collectionView.cellForItem(at: firstPath)?.alpha = 1
                            cell?.contentView.backgroundColor = .systemBlue
                            collectionView.cellForItem(at: firstPath)?.contentView.backgroundColor = .systemBlue
                        }
                        
                        self.score += 10
                        self.remainingPairs -= 2
                        self.checkForWin()
                        self.shuffleNumbers()
                    }
                }
            } else {
                // No match
                UIView.animate(withDuration: 0.3) {
                    collectionView.cellForItem(at: firstPath)?.contentView.backgroundColor = .systemBlue
                }
            }
            
            firstSelectedNumber = nil
            firstSelectedIndexPath = nil
            selectedNumberLabel.text = "Selected Number: None"
            
        } else {
            // First selection
            firstSelectedNumber = selectedNumber
            firstSelectedIndexPath = indexPath
            selectedNumberLabel.text = "Selected Number: \(selectedNumber)"
            
            UIView.animate(withDuration: 0.3) {
                cell?.contentView.backgroundColor = .systemYellow
            }
        }
    }
}

// MARK: - UICollectionView Drag & Drop Delegates
@available(iOS 14.0, *)
extension TrailThirdGameController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let number = numbers[indexPath.item]
        let itemProvider = NSItemProvider(object: String(number) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        selectedIndexPath = indexPath
        
        selectedNumberLabel.text = "Selected Number: \(number)"
        
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let selectedIndexPath = selectedIndexPath else { return }
        
        let draggedNumber = numbers[selectedIndexPath.item]
        let destinationNumber = numbers[destinationIndexPath.item]
        
        if draggedNumber == destinationNumber {
            // Match found
            numbers[selectedIndexPath.item] = Int.random(in: 1...100)
            numbers[destinationIndexPath.item] = Int.random(in: 1...100)
            score += 10
            
            // Add confetti animation if you have SPConfetti framework
            // SPConfetti.startAnimating(.centerWidthToUp, particles: [.triangle, .arc], duration: 1)
            
            shuffleNumbers()
        }
        
        self.selectedIndexPath = nil
        selectedNumberLabel.text = "Selected Number: None"
    }
}
