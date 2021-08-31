//
//  EventTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/30/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    let eventContainer: UIView = {
        let eventContainer = UIView()
        eventContainer.translatesAutoresizingMaskIntoConstraints = false
        eventContainer.layer.cornerRadius = 10
        eventContainer.backgroundColor = UIColor(named: "Green")
        return eventContainer
    }()
    
    let titleContainer: UIView = {
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = .black
        titleContainer.clipsToBounds = true
        titleContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        titleContainer.layer.cornerRadius = 10
        return titleContainer
    }()
    
    let titleTextField: UILabel = {
        let titleTextField = UILabel()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        titleTextField.textColor = .white
        titleTextField.numberOfLines = 0
        titleTextField.textAlignment = .center
        return titleTextField
    }()
    
    let timeContainer: UIView = {
        let timeContainer = UIView()
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        timeContainer.backgroundColor = UIColor(named: "Green")
        timeContainer.clipsToBounds = true
        timeContainer.layer.borderWidth = 3
        timeContainer.layer.borderColor = UIColor.white.cgColor
        return timeContainer
    }()
    
    let timeTextField: UILabel = {
        let timeTextField = UILabel()
        timeTextField.translatesAutoresizingMaskIntoConstraints = false
        timeTextField.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        timeTextField.textColor = .white
        timeTextField.numberOfLines = 0
        timeTextField.textAlignment = .center
        return timeTextField
    }()
    
    //let timeTextField = "yo"
    
    let bodyContainer: UIView = {
        let bodyContainer = UIView()
        bodyContainer.translatesAutoresizingMaskIntoConstraints = false
        bodyContainer.backgroundColor = UIColor(named: "Green")
        bodyContainer.layer.cornerRadius = 10
        bodyContainer.clipsToBounds = true
        return bodyContainer
    }()
    
    let bodyTextField: UILabel = {
        let bodyTextField = UILabel()
        bodyTextField.translatesAutoresizingMaskIntoConstraints = false
        bodyTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        bodyTextField.textColor = .white
        bodyTextField.numberOfLines = 0
        bodyTextField.textAlignment = .center
        return bodyTextField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .darkGray
        
        contentView.addSubview(eventContainer)
        eventContainer.addSubview(titleContainer)
        titleContainer.addSubview(titleTextField)
        eventContainer.addSubview(timeContainer)
        timeContainer.addSubview(timeTextField)
        eventContainer.addSubview(bodyContainer)
        bodyContainer.addSubview(bodyTextField)
        
        let titleTextFieldConstraints = [
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.widthAnchor.constraint(equalToConstant: 200)

        ]
        
        NSLayoutConstraint.activate(titleTextFieldConstraints)
        
        let titleContainerConstraints = [
            titleContainer.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -5),
            titleContainer.bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 0),
            titleContainer.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor, constant: -10),
            titleContainer.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(titleContainerConstraints)
        
        let timeTextFieldConstraints = [
            timeTextField.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 10),
            timeTextField.bottomAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 0),
            timeTextField.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor, constant: 0)
            //timeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            //timeTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(timeTextFieldConstraints)
        
        let timeContainerConstraints = [
            timeContainer.topAnchor.constraint(equalTo: timeTextField.topAnchor, constant: -5),
            timeContainer.bottomAnchor.constraint(equalTo: timeTextField.bottomAnchor, constant: 5),
            timeContainer.leadingAnchor.constraint(equalTo: timeTextField.leadingAnchor, constant: -10),
            timeContainer.trailingAnchor.constraint(equalTo: timeTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(timeContainerConstraints)
        
        let bodyTextFieldConstraints = [
            bodyTextField.topAnchor.constraint(equalTo: timeContainer.bottomAnchor, constant: 5),
            bodyTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            bodyTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyTextField.widthAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(bodyTextFieldConstraints)
        
        let bodyContainerConstraints = [
            bodyContainer.topAnchor.constraint(equalTo: bodyTextField.topAnchor, constant: -10),
            bodyContainer.bottomAnchor.constraint(equalTo: bodyTextField.bottomAnchor, constant: 5),
            bodyContainer.leadingAnchor.constraint(equalTo: bodyTextField.leadingAnchor, constant: -10),
            bodyContainer.trailingAnchor.constraint(equalTo: bodyTextField.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(bodyContainerConstraints)
        
        let eventContainerConstraints = [
            eventContainer.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 0),
            eventContainer.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor, constant: 0),
            eventContainer.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 0),
            eventContainer.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(eventContainerConstraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
