//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by MacPc4 on 8/21/25.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupOptimizedUI()
    }
    
    private func setupOptimizedUI() {
        // Simplified styling for better performance
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Optimize layer rendering
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Style labels efficiently
        tempLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tempLabel?.textColor = .white
        tempLabel?.textAlignment = .center
        
        iconImageView?.contentMode = .scaleAspectFit
        iconImageView?.tintColor = .white
    }
    
    func configure(with model: HourForecast) {
        // Set temperature efficiently
        tempLabel?.text = "\(Int(model.tempC))°"
        
        // Set weather icon without animations
        iconImageView?.image = getWeatherIcon(for: model.condition.text)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Efficient cleanup
        iconImageView?.image = nil
        tempLabel?.text = nil
        layer.removeAllAnimations()
    }
    
    private func getWeatherIcon(for condition: String) -> UIImage? {
        let icon = condition.lowercased()
        
        // Optimized icon selection using switch for better performance
        switch true {
        case icon.contains("sunny") || icon.contains("clear"):
            return UIImage(named: "clear")
        case icon.contains("partly cloudy") || icon.contains("partly sunny"):
            return UIImage(named: "partlycloudy")
        case icon.contains("cloudy") || icon.contains("overcast"):
            return UIImage(named: "cloud")
        case icon.contains("light rain") || icon.contains("patchy rain"):
            return UIImage(named: "lightrain")
        case icon.contains("moderate rain") || icon.contains("heavy rain"):
            return UIImage(named: "rain")
        case icon.contains("torrential rain") || icon.contains("violent rain") || icon.contains("shower"):
            return UIImage(named: "heavyrain")
        case icon.contains("sleet") || icon.contains("ice pellets") || icon.contains("freezing rain") || icon.contains("snow") || icon.contains("blizzard"):
            return UIImage(named: "snow")
        case icon.contains("thundery") || icon.contains("thunder"):
            return UIImage(named: "thunderstorm")
        case icon.contains("fog") || icon.contains("foggy") || icon.contains("mist") || icon.contains("haze"):
            return UIImage(named: "fog")
        case icon.contains("windy"):
            return UIImage(named: "windy")
        default:
            return UIImage(named: "clear")
        }
    }
}
