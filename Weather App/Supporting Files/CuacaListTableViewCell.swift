//
//  CuacaListTableViewCell.swift
//  Weather App
//
//  Created by Muhamad Septian Nugraha on 29/11/24.
//

import UIKit

class CuacaListTableViewCell: UITableViewCell {

    @IBOutlet weak var tanggalLabel: UILabel!
    @IBOutlet weak var kondisiLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var celciusLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        changeObject()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    // MARK: - Function untuk mengubah tampilan object pada saat siang dan malam hari.
    func changeObject() {
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        if currentHour >= 5 && currentHour <= 18 {
            
            backgroundImage.image = UIImage(named: "background-light")
            backgroundImage.alpha = 0.9
            
        } else {
            
            backgroundImage.image = UIImage(named: "background-night")
            backgroundImage.alpha = 0.9
            
            tanggalLabel.textColor = .white
            kondisiLabel.textColor = .white
            temperatureLabel.textColor = .white
            celciusLabel.textColor = .white
        }
    }
    
}
