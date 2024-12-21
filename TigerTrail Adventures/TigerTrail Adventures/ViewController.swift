//
//  ViewController.swift
//  TigerTrail Adventures
//
//  Created by jin fu on 2024/12/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var roadImageView: UIImageView!
    
    private var gameTimer: Timer?
    private var obstacles: [UIView] = []
    private var score: Int = 0
    private var isGameRunning = false
    private var roadScrollTimer: Timer?
    private var roadOffset: CGFloat = 0
    private var playerCar: UIImageView!
    private var longPressGesture: UILongPressGestureRecognizer!
    private let initialCarXPosition: CGFloat = 100
    private var gameTime: Int = 60 // Game duration in seconds
    private var countdownTimer: Timer?
    private var obstacleImages = ["obstacle1", "obstacle2", "obstacle3"] // Add your obstacle image names
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameUI()
        setupControls()
        setupRoadAnimation()
    }
    
    private func setupGameUI() {
        // Create player car programmatically with larger size
        playerCar = UIImageView(frame: CGRect(x: initialCarXPosition,
                                            y: view.bounds.height/2 - 40, // Adjusted for larger height
                                            width: 80,  // Increased width
                                            height: 160)) // Increased height
        
        // Set car image
        if let carImage = UIImage(named: "ic_car") {
            playerCar.image = carImage
        } else {
            playerCar.backgroundColor = .red
        }
        
        playerCar.contentMode = .scaleAspectFit
        playerCar.layer.zPosition = 100
        view.addSubview(playerCar)
        
        // Setup initial timer label
        timerLabel.text = "Time: \(gameTime)"
    }
    
    private func addRoadLines() {
        let lineSpacing: CGFloat = 80
        let lineHeight: CGFloat = 40
        let numberOfLines = Int(view.bounds.width / (lineSpacing))
        
        for i in 0...numberOfLines {
            let line = UIView(frame: CGRect(x: CGFloat(i) * lineSpacing,
                                          y: view.bounds.height/2 - 2,
                                          width: lineHeight,
                                          height: 4))
            line.backgroundColor = .white
            gameView.addSubview(line)
            obstacles.append(line)
        }
    }
    
    private func setupControls() {
        // Add up, down, and right swipe gestures
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Add long press gesture for returning to original position
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1 // Adjust this value for faster/slower response
        view.addGestureRecognizer(longPressGesture)
        
        // Add tap gesture to start game
        let tap = UITapGestureRecognizer(target: self, action: #selector(startGame))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard isGameRunning else { return }
        
        let movement: CGFloat = 50
        
        switch gesture.direction {
        case .up:
            let newY = max(20, playerCar.frame.minY - movement)
            UIView.animate(withDuration: 0.2) {
                self.playerCar.frame.origin.y = newY
            }
            
        case .down:
            let newY = min(view.bounds.height - playerCar.frame.height - 20,
                          playerCar.frame.minY + movement)
            UIView.animate(withDuration: 0.2) {
                self.playerCar.frame.origin.y = newY
            }
            
        case .right:
            // Boost forward with acceleration effect
            let boostDistance: CGFloat = 100
            let currentX = playerCar.frame.origin.x
            let maxX = min(currentX + boostDistance, view.bounds.width - playerCar.frame.width - 20)
            
            UIView.animate(withDuration: 0.3,
                          delay: 0,
                          options: [.curveEaseOut],
                          animations: {
                self.playerCar.frame.origin.x = maxX
            })
            
        default:
            break
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard isGameRunning else { return }
        
        switch gesture.state {
        case .began, .changed:
            // Gradually move car back to initial position
            let currentX = playerCar.frame.origin.x
            if currentX > initialCarXPosition {
                UIView.animate(withDuration: 0.2) {
                    self.playerCar.frame.origin.x = max(self.initialCarXPosition,
                                                      currentX - 10) // Adjust speed by changing this value
                }
            }
        default:
            break
        }
    }
    
    @objc private func startGame() {
        guard !isGameRunning else { return }
        isGameRunning = true
        score = 0
        gameTime = 60 // Reset timer
        scoreLabel.text = "Score: 0"
        timerLabel.text = "Time: \(gameTime)"
        
        // Reset car position when game starts
        resetCarPosition()
        
        // Start game loop
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        // Start countdown timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Start road animation
        startRoadAnimation()
    }
    
    private func updateGame() {
        // Update score
        score += 1
        scoreLabel.text = "Score: \(score)"
        
        // Random obstacle generation (adjust frequency as needed)
        if Int.random(in: 1...100) <= 2 { // 2% chance per update
            createObstacle()
        }
        
        // Check collision before updating obstacle positions
        checkCollision()
    }
    
    private func createObstacle() {
        let obstacleSize = CGSize(width: 60, height: 120)
        let randomY = CGFloat.random(in: gameView.bounds.minY...(gameView.bounds.height - obstacleSize.height))
        
        let obstacle = UIImageView(frame: CGRect(x: gameView.bounds.width + obstacleSize.width,
                                               y: randomY,
                                               width: obstacleSize.width,
                                               height: obstacleSize.height))
        
        if let randomObstacle = obstacleImages.randomElement(),
           let obstacleImage = UIImage(named: randomObstacle) {
            obstacle.image = obstacleImage
        } else {
            obstacle.backgroundColor = .yellow // Fallback color to make collision visible
        }
        
        obstacle.contentMode = .scaleAspectFit
        obstacle.layer.zPosition = 100
        
        gameView.addSubview(obstacle)
        obstacles.append(obstacle)
        
        UIView.animate(withDuration: 2.0,
                      delay: 0,
                      options: [.curveLinear],
                      animations: {
            obstacle.frame.origin.x = -obstacleSize.width
        }) { [weak self] _ in
            obstacle.removeFromSuperview()
            if let index = self?.obstacles.firstIndex(of: obstacle) {
                self?.obstacles.remove(at: index)
            }
        }
    }
    
    @IBAction func btnBack(_ sender : UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    private func checkCollision() {
        for obstacle in obstacles {
            // Convert frames to the same coordinate space
            let obstacleFrameInView = gameView.convert(obstacle.frame, to: view)
            
            // Create slightly larger collision frame for the car (more forgiving)
            let carCollisionFrame = CGRect(x: playerCar.frame.origin.x + 10, // Adjust collision box
                                         y: playerCar.frame.origin.y + 10,
                                         width: playerCar.frame.width - 20,
                                         height: playerCar.frame.height - 20)
            
            // Check if frames intersect
            if carCollisionFrame.intersects(obstacleFrameInView) {
                print("Collision detected!") // Debug print
                showGameOverAnimation()
                return // Exit immediately after collision
            }
        }
    }
    
    private func showGameOverAnimation() {
        // Ensure we haven't already stopped the game
        guard isGameRunning else { return }
        
        // Stop all game timers immediately
        gameTimer?.invalidate()
        gameTimer = nil
        roadScrollTimer?.invalidate()
        roadScrollTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        isGameRunning = false
        
        // Flash the car red to indicate collision
        UIView.animate(withDuration: 0.2, animations: {
            self.playerCar.alpha = 0.5
            self.playerCar.backgroundColor = .red
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.playerCar.alpha = 1.0
            }) { _ in
                // Ensure we're on the main thread for UI updates
                DispatchQueue.main.async {
                    self.showGameOverAlert()
                }
            }
        }
        
        // Optional: Add shake animation to the car
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        playerCar.layer.add(animation, forKey: "shake")
    }
    
    private func showGameOverAlert() {
        // Ensure we're on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.showGameOverAlert()
            }
            return
        }
        
        print("Showing game over alert") // Debug print
        
        let alert = UIAlertController(title: "Game Over!",
                                    message: "You crashed!\nScore: \(score)",
                                    preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.resetGame()
        }
        
        alert.addAction(restartAction)
        present(alert, animated: true)
    }
    
    private func resetGame() {
        // Reset car position and appearance
        resetCarPosition()
        playerCar.backgroundColor = nil
        playerCar.alpha = 1.0
        
        // Remove all existing obstacles
        for obstacle in obstacles {
            obstacle.removeFromSuperview()
        }
        obstacles.removeAll()
        
        // Reset score and timer
        score = 0
        gameTime = 60
        scoreLabel.text = "Score: 0"
        timerLabel.text = "Time: \(gameTime)"
        
        // Reset road position
        if let containerView = roadImageView.subviews.first {
            containerView.frame.origin.x = 0
        }
    }
    
    private func setupRoadAnimation() {
        // Make sure the road image is set to repeat
        roadImageView.contentMode = .scaleToFill
        roadImageView.clipsToBounds = true
        
        // Create a container view for the scrolling images
        let containerView = UIView(frame: CGRect(x: 0, y: 0,
                                               width: roadImageView.bounds.width * 2,
                                               height: roadImageView.bounds.height))
        containerView.clipsToBounds = true
        roadImageView.addSubview(containerView)
        
        // Create two road images for seamless scrolling
        let firstRoadImage = UIImageView(frame: CGRect(x: 0, y: 0,
                                                     width: roadImageView.bounds.width,
                                                     height: roadImageView.bounds.height))
        firstRoadImage.image = roadImageView.image
        firstRoadImage.contentMode = .scaleToFill
        
        let secondRoadImage = UIImageView(frame: CGRect(x: roadImageView.bounds.width, y: 0,
                                                      width: roadImageView.bounds.width,
                                                      height: roadImageView.bounds.height))
        secondRoadImage.image = roadImageView.image
        secondRoadImage.contentMode = .scaleToFill
        
        containerView.addSubview(firstRoadImage)
        containerView.addSubview(secondRoadImage)
        
        // Clear the original image
        roadImageView.image = nil
    }
    
    private func startRoadAnimation() {
        // Stop any existing animation
        roadScrollTimer?.invalidate()
        
        // Start new animation
        roadScrollTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Move the container view
            if let containerView = self.roadImageView.subviews.first {
                containerView.frame.origin.x -= 2 // Adjust speed here
                
                // Reset position when needed
                if containerView.frame.origin.x <= -self.roadImageView.bounds.width {
                    containerView.frame.origin.x = 0
                }
            }
        }
    }
    
    private func updateTimer() {
        gameTime -= 1
        timerLabel.text = "Time: \(gameTime)"
        
        if gameTime <= 0 {
            self.showGameOverAlert()
            print("GameOver")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update player car position after layout changes
        if !isGameRunning {
            playerCar.frame = CGRect(x: initialCarXPosition,
                                   y: view.bounds.height/2 - 40, // Adjusted for larger height
                                   width: 80,  // Increased width
                                   height: 160) // Increased height
        }
        
        // Update container and image views frames after layout
        if let containerView = roadImageView.subviews.first {
            containerView.frame = CGRect(x: containerView.frame.origin.x, y: 0,
                                       width: roadImageView.bounds.width * 2,
                                       height: roadImageView.bounds.height)
            
            if let firstImage = containerView.subviews.first,
               let secondImage = containerView.subviews.last {
                firstImage.frame = CGRect(x: 0, y: 0,
                                        width: roadImageView.bounds.width,
                                        height: roadImageView.bounds.height)
                secondImage.frame = CGRect(x: roadImageView.bounds.width, y: 0,
                                         width: roadImageView.bounds.width,
                                         height: roadImageView.bounds.height)
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // Add this method to prevent auto-rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    // Add this method to reset car position when game starts/restarts
    private func resetCarPosition() {
        playerCar.frame = CGRect(x: initialCarXPosition,
                               y: view.bounds.height/2 - 40, // Adjusted for larger height
                               width: 80,  // Increased width
                               height: 160) // Increased height
    }
}

