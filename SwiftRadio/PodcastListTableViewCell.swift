//
//  PodcastListTableViewCell.swift
//  KaFa Radio
//
//  Created by Emre Işık on 6.03.2019.
//  Copyright © 2019 emreisik.com.tr. All rights reserved.
//

import UIKit

class PodcastListTableViewCell: UITableViewCell {

    @IBOutlet var podcastListDesc: UILabel!
    @IBOutlet var podcastListImageView: UIImageView!
    @IBOutlet var podcastListNameLabel: UILabel!
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
        podcastListNameLabel.text = station.name
        podcastListDesc.text = station.longDesc
        
        let imageURL = station.imageURL as NSString
        
        if imageURL.contains("http") {
            
            if let url = URL(string: station.imageURL) {
                podcastListImageView.loadImageWithURL(url: url) { (image) in
                    // station image loaded
                }
            }
            
        } else if imageURL != "" {
            podcastListImageView.image = UIImage(named: imageURL as String)
            
        } else {
            podcastListImageView.image = UIImage(named: "stationImage")
        }
        
        podcastListImageView.applyShadow()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        podcastListNameLabel.text  = nil
        podcastListDesc.text       = nil
        podcastListImageView.image = nil
    }
}
