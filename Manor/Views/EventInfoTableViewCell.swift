//
//  EventInfoTableViewCell.swift
//  Manor
//
//  Created by Colin Birkenstock on 9/9/21.
//

import UIKit

class EventInfoTableViewCell: UITableViewCell {

    let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        return containerView
    }()
    
    var eventDescriptionLabel: UILabel  = {
        let eventDescriptionLabel = UILabel()
        eventDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        eventDescriptionLabel.textColor = .white
        eventDescriptionLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        eventDescriptionLabel.backgroundColor = .clear
        eventDescriptionLabel.numberOfLines = 0
        return eventDescriptionLabel
    }()
    
    var descriptionString: UILabel  = {
        let descriptionString = UILabel()
        descriptionString.translatesAutoresizingMaskIntoConstraints = false
        descriptionString.textColor = UIColor(named: K.BrandColors.purple)
        descriptionString.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        descriptionString.backgroundColor = .clear
        descriptionString.numberOfLines = 0
        descriptionString.text = "Description:"
        return descriptionString
    }()
    
    var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        timeLabel.backgroundColor = .clear
        return timeLabel
    }()
    
    var timeString: UILabel = {
        let timeString = UILabel()
        timeString.translatesAutoresizingMaskIntoConstraints = false
        timeString.textColor = UIColor(named: K.BrandColors.purple)
        timeString.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        timeString.backgroundColor = .clear
        timeString.text = "Time:"
        return timeString
    }()
    
    var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        dateLabel.backgroundColor = .clear
        return dateLabel
    }()
    
    var dateString: UILabel = {
        let dateString = UILabel()
        dateString.translatesAutoresizingMaskIntoConstraints = false
        dateString.textColor = UIColor(named: K.BrandColors.purple)
        dateString.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        dateString.backgroundColor = .clear
        dateString.text = "Date:"
        return dateString
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        self.addSubview(eventDescriptionLabel)
        self.addSubview(descriptionString)
        self.addSubview(dateLabel)
        self.addSubview(dateString)
        self.addSubview(timeLabel)
        self.addSubview(timeString)
        
        let eventDescriptionLabelConstraints = [
            eventDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            eventDescriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            eventDescriptionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 50),
        ]
        
        NSLayoutConstraint.activate(eventDescriptionLabelConstraints)
        
        let descriptionStringConstraints = [
            descriptionString.topAnchor.constraint(equalTo: eventDescriptionLabel.topAnchor, constant: 0),
            descriptionString.leadingAnchor.constraint(equalTo: eventDescriptionLabel.leadingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(descriptionStringConstraints)
        
        let timeLabelConstraints = [
            timeLabel.bottomAnchor.constraint(equalTo: eventDescriptionLabel.topAnchor, constant: -5),
            timeLabel.leadingAnchor.constraint(equalTo: eventDescriptionLabel.leadingAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(timeLabelConstraints)
        
        let timeStringConstraints = [
            timeString.topAnchor.constraint(equalTo: timeLabel.topAnchor, constant: 0),
            timeString.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(timeStringConstraints)
        
        let dateLabelConstraints = [
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            dateLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -5),
            dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            dateLabel.leadingAnchor.constraint(equalTo: eventDescriptionLabel.leadingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(dateLabelConstraints)
        
        let dateStringConstraints = [
            dateString.topAnchor.constraint(equalTo: dateLabel.topAnchor, constant: 0),
            dateString.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(dateStringConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
