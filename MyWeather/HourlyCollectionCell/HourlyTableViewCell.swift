//
//  HourlyTableViewCell.swift
//  MyWeather
//
//  Created by MacPc4 on 8/17/25.
//

import UIKit

class HourlyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    var models = [HourForecast]()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Configure collection view for better performance
        if collectionView != nil {
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            
            // Optimize layout for performance
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumInteritemSpacing = 12
                layout.minimumLineSpacing = 12
                layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            }
        }
        
        collectionView.register(WeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Enable prefetching for smoother scrolling
        collectionView.isPrefetchingEnabled = true
    }

    static let identifier = "HourlyTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyTableViewCell", bundle: nil)
    }
    
    func configure(with models: [HourForecast]) {
        self.models = models
        collectionView.reloadData()
        
        // Remove heavy animations for better performance
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120) // Slightly smaller for better performance
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(models.count, 24) // Limit to 24 hours for better performance
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        cell.configure(with: models[indexPath.row])
        
        return cell
    }
}
