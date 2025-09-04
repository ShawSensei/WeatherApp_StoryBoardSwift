//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by MacPc4 on 8/17/25.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // Container view for modern card design
    private let cardView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupModernUI()
        // Remove setupConstraints() call since XIB already has constraints
    }
    
    private func setupModernUI() {
        // Clear default background
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Setup card container with simplified styling
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        cardView.layer.cornerRadius = 20
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Simplified shadow for better performance
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        cardView.layer.shouldRasterize = true
        cardView.layer.rasterizationScale = UIScreen.main.scale
        
        // Add card to content view BEHIND existing elements
        contentView.insertSubview(cardView, at: 0)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        
        // Style existing XIB elements without changing their constraints
        dayLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        dayLabel.textColor = .white
        
        highTempLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        highTempLabel.textColor = .white
        highTempLabel.textAlignment = .center
        
        lowTempLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lowTempLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        lowTempLabel.textAlignment = .center
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
    }
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configure(with model: ForecastDay) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        
        self.lowTempLabel.text = "\(Int(model.day.mintempC))°"
        self.highTempLabel.text = "\(Int(model.day.maxtempC))°"
        
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.dateEpoch)))
        
        self.iconImageView.image = UIImage(named: "clear")
        self.iconImageView.contentMode = .scaleAspectFit
        
        let icon = model.day.condition.text.lowercased()
        // Clear/Sunny conditions
        if icon.contains("sunny") || icon.contains("clear") {
            self.iconImageView.image = UIImage(named: "clear")
        }
        // Cloudy conditions
        else if icon.contains("partly cloudy") || icon.contains("partly sunny") {
            self.iconImageView.image = UIImage(named: "partlycloudy")
        }
        else if icon.contains("cloudy") || icon.contains("overcast") {
            self.iconImageView.image = UIImage(named: "cloud")
        }
        // Rain conditions
        else if icon.contains("light rain") || icon.contains("patchy rain") {
            self.iconImageView.image = UIImage(named: "lightrain")
        }
        else if icon.contains("moderate rain") || icon.contains("heavy rain") {
            self.iconImageView.image = UIImage(named: "rain")
        }
        else if icon.contains("torrential rain") || icon.contains("violent rain")  || icon.contains("shower") {
            self.iconImageView.image = UIImage(named: "heavyrain")
        }
        //                else if icon.contains("shower") {
        //                    self.iconImageView.image = UIImage(named: "shower")
        //                }
        // Snow conditions
        //                else if icon.contains("blizzard") {
        //                    self.iconImageView.image = UIImage(named: "blizzard")
        //                }
        //                else if icon.contains("heavy snow") {
        //                    self.iconImageView.image = UIImage(named: "heavysnow")
        //                }
        //                else if icon.contains("light snow") || icon.contains("patchy snow") {
        //                    self.iconImageView.image = UIImage(named: "lightsnow")
        //                }
        else if icon.contains("sleet") || icon.contains("ice pellets") || icon.contains("freezing rain") || icon.contains("freezing drizzle") || icon.contains("snow") || icon.contains("blizzard") || icon.contains("light snow") || icon.contains("patchy snow")||icon.contains("heavy snow") {
            self.iconImageView.image = UIImage(named: "snow")
        }
        // Sleet/Ice conditions
        //                else if icon.contains("sleet") || icon.contains("ice pellets") {
        //                    self.iconImageView.image = UIImage(named: "sleet")
        //                }
        //                else if icon.contains("freezing rain") || icon.contains("freezing drizzle") {
        //                    self.iconImageView.image = UIImage(named: "freezingrain")
        //                }
        // Thunderstorm conditions
        else if icon.contains("thundery") || icon.contains("thunder") {
            self.iconImageView.image = UIImage(named: "thunderstorm")
        }
        // Fog/Mist conditions
        else if icon.contains("fog") || icon.contains("foggy") || icon.contains("mist") || icon.contains("haze") {
            self.iconImageView.image = UIImage(named: "fog")
        }
        //                else if icon.contains("mist") || icon.contains("haze") {
        //                    self.iconImageView.image = UIImage(named: "mist")
        //                }
        // Wind conditions
        else if icon.contains("windy") {
            self.iconImageView.image = UIImage(named: "windy")
        }
        // Default fallback
        else {
            self.iconImageView.image = UIImage(named: "clear")
        }
        
        self.iconImageView.contentMode = .scaleAspectFit
    }
    
    func getDayForDate(_ date:Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: inputDate)
    }
        
    
}
