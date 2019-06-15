//
//  ViewController.swift
//  BetterRest
//
//  Created by Piotr Sirek on 15/06/2019.
//  Copyright © 2019 Piotr Sirek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var wakeUpTime: UIDatePicker!
    
    var sleepAmountTime: UIStepper!
    var sleepAmountLabel: UILabel!
    
    var coffeeAmountStepper: UIStepper!
    var coffeeAmountLabel: UILabel!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        let wakeUpLabel = UILabel()
        wakeUpLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpLabel.numberOfLines = 0
        wakeUpLabel.text = "When do you want to wake up?"
        mainStackView.addArrangedSubview(wakeUpLabel)
        
        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 15
        mainStackView.addArrangedSubview(wakeUpTime)
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()
        
        let sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = "What's minimum amount of sleep you need?"
        mainStackView.addArrangedSubview(sleepTitle)
        
        sleepAmountTime = UIStepper()
        sleepAmountTime.stepValue = 0.25
        sleepAmountTime.value = 8
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 12
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChange), for: .valueChanged)
        
        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        let sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)
        
        let coffeeTitle = UILabel()
        coffeeTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitle.numberOfLines = 0
        coffeeTitle.text = "How much coffe do you drink each day?"
        mainStackView.addArrangedSubview(coffeeTitle)
        
        coffeeAmountStepper = UIStepper()
        coffeeAmountStepper.minimumValue = 1
        coffeeAmountStepper.maximumValue = 20
        coffeeAmountStepper.addTarget(self, action: #selector(coffeeAmountChange), for: .valueChanged)
        
        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        let coffeeStackView = UIStackView()
        coffeeStackView.spacing = 20
        coffeeStackView.addArrangedSubview(coffeeAmountStepper)
        coffeeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeeStackView)
        
        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitle)
        
        sleepAmountChange()
        coffeeAmountChange()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Better Rest"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate", style: .plain, target: self, action: #selector(calculateBedtime))
    }
    
    @objc func sleepAmountChange() {
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }
    
    @objc func coffeeAmountChange() {
        if coffeeAmountStepper.value == 1 {
            coffeeAmountLabel.text = "1 cup"
        } else {
            coffeeAmountLabel.text = "\(Int(coffeeAmountStepper.value)) cups"
        }
    }
    
    @objc func calculateBedtime() {
        let model = SleepCalculator()
        
        let title: String
        let message: String
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(coffee: coffeeAmountStepper.value, estimatedSleep: sleepAmountTime.value, wake: Double(hour + minute))
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)
            
            title = "Your ideal bedtime is..."
        } catch {
            title = "Error"
            message = "Sorry that was a problem to calculate your bedtime."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

