//
//  GameViewController.swift
//  RainbowGame
//
//  Created by sidzhe on 12.11.2023.
//

import UIKit
import SnapKit

final class GameViewController: UIViewController {
    let background = Background()
    var cardViews: [RainbowCardView] = []
    let colorSelection = ColorSelection()
    var timer: Timer?
    var secondsPassed: Int = 0
    var isTimerPaused: Bool = false
    var isRandomLocationOn: Bool = true
    let gameTime = 120
    var updateTime = 20
    lazy var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("X2", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(nextCards) , for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackGround()
        setupNavBar()
        setupCards()
        setupButton()
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    private func setupCards() {
        let colors = colorSelection.gameColorSelection(gameColors: ColorModel.gameColors)
        var top = 120
        for i in 0...colors.count - 1 {
            let card = RainbowCardView(cardBackgroundColor: colors[i].1 , labelText: colors[i].0)
            card.delegate = self
            view.addSubview(card)
            ifRandomLocationOn(top: top, card: card)
            top += (Int(view.frame.height) - 120) / 7
            cardViews.append(card)
        }
    }
    
    private func ifRandomLocationOn(top : Int, card: RainbowCardView) {
        if isRandomLocationOn {
            let leading = Int.random(in: 20...150)
            card.snp.makeConstraints { make in
                make.leading.equalTo(leading)
            }
        } else {
            card.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
            }
        }
        card.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.height.equalTo(44)
            make.width.equalTo(200)
        }
    }
    
    private func setupBackGround() {
        view.backgroundColor = .white
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavBar() {
        title = formatTime(seconds: gameTime)
        let customLeftButton = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(backButtonTapped))
        let customRightButton = UIBarButtonItem(image: UIImage(named: "pauseButton"), style: .plain, target: self, action: #selector(pauseButtonTapped))
        customLeftButton.tintColor = .black
        customRightButton.tintColor = .black
        navigationItem.leftBarButtonItem = customLeftButton
        navigationItem.rightBarButtonItem = customRightButton
        navigationItem.rightBarButtonItem?.isSelected = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
        ]
    }
    
    private func setupButton() {
        view.addSubview(updateButton)
        updateButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(50)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    private func formatTime(seconds: Int) -> String {
        // Функция для форматирования времени в формат "00:00"
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func nextCards() {
        guard updateTime > 2 else {
            updateButton.isHidden = true
            return
        }
        updateTime /= 2
    }
    
    @objc func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func pauseButtonTapped() {
        isTimerPaused.toggle()
        guard let isSelected = navigationItem.rightBarButtonItem?.isSelected else {return}
        if !isSelected {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "playButton")
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "pauseButton")
        }
        navigationItem.rightBarButtonItem?.isSelected.toggle()
    }
    
    @objc func updateTimer() {
        guard !isTimerPaused else {
            updateButton.isEnabled = false
            return
        }
        updateButton.isEnabled = true
        secondsPassed += 1
        title = formatTime(seconds: gameTime - secondsPassed)
        if secondsPassed == gameTime {
            timer?.invalidate()
            present(ResultsViewController(), animated: true)
        } else if secondsPassed % updateTime == 0 {
            cardViews.forEach { $0.removeFromSuperview() }
            setupCards()
        }
    }
}


extension GameViewController: CheckViewDelegate {
    func button() {
        print("Check +1")
    }
    
    
}
//
//#Preview {
//    GameViewController()
//}
