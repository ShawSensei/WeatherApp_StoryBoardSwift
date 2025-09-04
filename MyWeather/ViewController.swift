//
//  ViewController.swift
//  MyWeather
//
//  Created by MacPc4 on 8/14/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    
    var models = [ForecastDay]()
    var hourlyModels = [HourForecast]()
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var current: Current?
    
    // Gradient layer for background
    private let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModernUI()
        setupTableView()
        setupGradientBackground()
    }
    
    private func setupModernUI() {
        // Hide navigation bar for full screen experience
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set status bar style
        overrideUserInterfaceStyle = .dark
    }
    
    private func setupTableView() {
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        // Modern table view styling
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        
        // Add some top padding for status bar
        table.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 20, right: 0)
    }
    
    private func setupGradientBackground() {
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0).cgColor,
            UIColor(red: 46/255.0, green: 94/255.0, blue: 161/255.0, alpha: 1.0).cgColor,
            UIColor(red: 28/255.0, green: 58/255.0, blue: 108/255.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    //Location
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation(){
        guard let currentLocation = currentLocation else {
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = "https://api.weatherapi.com/v1/forecast.json?key=78f1c790fef942aebe950202251808&q=\(lat),\(long)&days=7&aqi=no&alerts=no"
        
        URLSession.shared.dataTask(with: URL(string:url)!, completionHandler: { data, response, error in
            
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            
            var json: WeatherResponse?
            do {
                json = try JSONDecoder.weatherAPIDecoder.decode(WeatherResponse.self, from: data)
            } catch {
                print("Failed to decode JSON: \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            let entries = result.forecastDays
            self.models.append(contentsOf: entries)
            
            self.current = result.current
            self.hourlyModels = result.hourly
            
            DispatchQueue.main.async {
                self.models = result.forecastDays
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeader()
                
                // Add smooth animation
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut) {
                    self.table.alpha = 1.0
                } completion: { _ in
                    // Add subtle bounce animation to cells
                    self.animateTableViewCells()
                }
            }
            
            print("Current condition: \(result.current.condition.text)")
            print("Location: \(result.location.name)")
            print("Temperature: \(result.current.tempC)°C")
            print("Current Location: \(long), \(lat)")
        }).resume()
    }
    
    private func animateTableViewCells() {
        let cells = table.visibleCells
        let tableHeight = table.bounds.size.height
        
        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 280))
        headerView.backgroundColor = .clear
        
        // Container view with modern styling
        let containerView = UIView(frame: CGRect(x: 20, y: 20, width: view.frame.size.width - 40, height: 250))
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 25
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 20
        
        // Add subtle border
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Location label with modern typography
        let locationLabel = UILabel(frame: CGRect(x: 20, y: 20, width: containerView.frame.width - 40, height: 30))
        locationLabel.text = "Current Location"
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        locationLabel.textColor = .white
        locationLabel.alpha = 0.9
        
        // Weather condition with improved styling
        let summaryLabel = UILabel(frame: CGRect(x: 20, y: 50, width: containerView.frame.width - 40, height: 35))
        summaryLabel.text = self.current?.condition.text ?? "Loading..."
        summaryLabel.textAlignment = .center
        summaryLabel.font = UIFont.systemFont(ofSize: 22, weight: .light)
        summaryLabel.textColor = .white
        
        // Large temperature display
        let tempLabel = UILabel(frame: CGRect(x: 20, y: 90, width: containerView.frame.width - 40, height: 120))
        tempLabel.text = "\(Int(self.current?.tempC ?? 0))°"
        tempLabel.font = UIFont.systemFont(ofSize: 80, weight: .ultraLight)
        tempLabel.textAlignment = .center
        tempLabel.textColor = .white
        
        // Add weather details row
        let detailsView = createWeatherDetailsView(frame: CGRect(x: 20, y: 190, width: containerView.frame.width - 40, height: 40))
        
        containerView.addSubview(locationLabel)
        containerView.addSubview(summaryLabel)
        containerView.addSubview(tempLabel)
        containerView.addSubview(detailsView)
        
        headerView.addSubview(containerView)
        
        // Add entrance animation
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
            containerView.transform = CGAffineTransform.identity
            containerView.alpha = 1.0
        }
        
        return headerView
    }
    
    private func createWeatherDetailsView(frame: CGRect) -> UIView {
        let detailsView = UIView(frame: frame)
        
        let humidity = self.current?.humidity ?? 0
        let windSpeed = self.current?.windKph ?? 0
        let feelsLike = self.current?.feelslikeC ?? 0
        
        let details = [
            ("Humidity", "\(humidity)%"),
            ("Wind", "\(Int(windSpeed)) km/h"),
            ("Feels like", "\(Int(feelsLike))°")
        ]
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.frame = detailsView.bounds
        
        for detail in details {
            let containerView = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = detail.0
            titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            titleLabel.textAlignment = .center
            
            let valueLabel = UILabel()
            valueLabel.text = detail.1
            valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            valueLabel.textColor = .white
            valueLabel.textAlignment = .center
            
            containerView.addSubview(titleLabel)
            containerView.addSubview(valueLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
        
        detailsView.addSubview(stackView)
        return detailsView
    }
    
    //table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Only one row for hourly forecast
        }
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180 // Much taller for enhanced hourly forecast with title
        }
        return 100 // Taller for daily forecast with larger icons
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = .clear
            
            let label = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.frame.width - 40, height: 20))
            label.text = "7-Day Forecast"
            label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            label.textColor = .white
            
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 0
    }
}

// Top-level response for WeatherAPI /forecast.json
struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast?

    // Direct access to all models
    var daily: [DayForecast] {
        return forecast?.days.map { $0.day } ?? []
    }
    
    var hourly: [HourForecast] {
        return forecast?.days.first?.hour ?? []
    }
    
    var forecastDays: [ForecastDay] {
        return forecast?.days ?? []
    }
    
    var astro: Astro? {
        return forecast?.days.first?.astro
    }
    
    var condition: Condition {
        return current.condition
    }
    
    // All hourly forecasts for all days
    var allHourlyForecasts: [HourForecast] {
        return forecast?.days.flatMap { $0.hour } ?? []
    }
    
    // Current weather data
    var currentWeather: Current {
        return current
    }
    
    // Location data
    var locationData: Location {
        return location
    }
    
    // Complete forecast data
    var forecastData: Forecast? {
        return forecast
    }
}

// MARK: - Location
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tzId: String
    let localtimeEpoch: Int
    let localtime: String
}

// MARK: - Current
struct Current: Codable {
    let lastUpdatedEpoch: Int
    let lastUpdated: String
    let tempC: Double
    let tempF: Double
    let isDay: Int
    let condition: Condition
    let windMph: Double
    let windKph: Double
    let windDegree: Int
    let windDir: String
    let pressureMb: Double
    let pressureIn: Double
    let precipMm: Double
    let precipIn: Double
    let humidity: Int
    let cloud: Int
    let feelslikeC: Double
    let feelslikeF: Double
    let windchillC: Double?
    let windchillF: Double?
    let heatindexC: Double?
    let heatindexF: Double?
    let dewpointC: Double?
    let dewpointF: Double?
    let visKm: Double
    let visMiles: Double
    let uv: Double
    let gustMph: Double
    let gustKph: Double

    // Solar/radiation fields (may not always be present -> optional)
    let shortRad: Double?
    let diffRad: Double?
    let dni: Double?
    let gti: Double?
}

// MARK: - Condition
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast
struct Forecast: Codable {
    // WeatherAPI uses "forecastday" in JSON; map it to a nicer name.
    let days: [ForecastDay]

    private enum CodingKeys: String, CodingKey {
        case days = "forecastday"
    }
}

struct ForecastDay: Codable {
    let date: String
    let dateEpoch: Int
    let day: DayForecast
    let astro: Astro
    let hour: [HourForecast]
}

struct DayForecast: Codable {
    let maxtempC: Double
    let maxtempF: Double
    let mintempC: Double
    let mintempF: Double
    let avgtempC: Double
    let avgtempF: Double
    let maxwindMph: Double
    let maxwindKph: Double
    let totalprecipMm: Double
    let totalprecipIn: Double
    let totalsnowCm: Double
    let avgvisKm: Double
    let avgvisMiles: Double
    let avghumidity: Double
    let dailyWillItRain: Int
    let dailyChanceOfRain: Int
    let dailyWillItSnow: Int
    let dailyChanceOfSnow: Int
    let condition: Condition
    let uv: Double
}

struct Astro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moonPhase: String
    let moonIllumination: Int
    let isMoonUp: Int
    let isSunUp: Int
}

struct HourForecast: Codable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let tempF: Double
    let isDay: Int
    let condition: Condition

    let windMph: Double
    let windKph: Double
    let windDegree: Int
    let windDir: String
    let pressureMb: Double
    let pressureIn: Double
    let precipMm: Double
    let precipIn: Double
    let humidity: Int
    let cloud: Int
    let feelslikeC: Double
    let feelslikeF: Double
    let windchillC: Double?
    let windchillF: Double?
    let heatindexC: Double?
    let heatindexF: Double?
    let dewpointC: Double?
    let dewpointF: Double?
    let willItRain: Int?
    let chanceOfRain: Int?
    let willItSnow: Int?
    let chanceOfSnow: Int?
    let visKm: Double
    let visMiles: Double
    let gustMph: Double
    let gustKph: Double
    let uv: Double

    // Sometimes present in datasets
    let shortRad: Double?
    let diffRad: Double?
    let dni: Double?
    let gti: Double?
}

// MARK: - JSON Decoder helper
extension JSONDecoder {
    static var weatherAPIDecoder: JSONDecoder {
        let d = JSONDecoder()
        // WeatherAPI uses snake_case; this maps to our camelCase properties
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }
    
    //siibham weird
}
