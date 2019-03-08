//
//  PodcastTableViewCell.swift
//  KaFa Radio
//
//  Created by Emre Işık on 5.03.2019.
//  Copyright © 2019 emreisik.com.tr. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    @IBOutlet var podcastImageView: UIImageView!
    @IBOutlet var podcastNameLabel: UILabel!
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set table selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 78/255, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView  = selectedView
    }
    
    func configureStationCell(station: RadioStation) {
        
        // Configure the cell...
        podcastNameLabel.text = station.name
        
        let imageURL = station.imageURL as NSString
        
        if imageURL.contains("http") {
            
            if let url = URL(string: station.imageURL) {
                podcastImageView.loadImageWithURL(url: url) { (image) in
                    // station image loaded
                }
            }
            
        } else if imageURL != "" {
            podcastImageView.image = UIImage(named: imageURL as String)
            
        } else {
            podcastImageView.image = UIImage(named: "stationImage")
        }
        
        podcastImageView.applyShadow()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        podcastNameLabel.text  = nil
        podcastImageView.image = nil
    }
}
