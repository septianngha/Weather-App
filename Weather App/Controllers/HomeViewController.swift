//
//  HomeViewController.swift
//  Weather App
//
//  Created by Muhamad Septian Nugraha on 30/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var salamValue: UILabel!
    @IBOutlet weak var namaValue: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    @IBOutlet weak var temperatureValue: UILabel!
    @IBOutlet weak var celciusLabel: UILabel!
    @IBOutlet weak var kondisiCuacaValue: UILabel!
    @IBOutlet weak var namaKotaValue: UILabel!
    
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var textPrakiraanLabel: UILabel!
    
    var weatherData: WeatherModel?
    var fiveDaysModel: [FiveDaysModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        changeObject()
        getIconAndData()
        registerCell()
        getData5HariKedepan()
        
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
    }
    
    
    // MARK: - Register untuk Custom Table Cell
    func registerCell() {
        
        let nib = UINib(nibName: "CuacaListTableViewCell", bundle: nil)
        weatherTableView.register(nib, forCellReuseIdentifier: "weatherCell")
        
        weatherTableView.rowHeight = 123.0
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiveDaysModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? CuacaListTableViewCell else {
            return UITableViewCell()
        }
        
        let objectData = fiveDaysModel[indexPath.row]
        cell.tanggalLabel.text = objectData.date
        cell.kondisiLabel.text = objectData.conditionName
        cell.temperatureLabel.text = objectData.temperatureString
        
        let iconCode = objectData.icon
        let iconURL = "http://openweathermap.org/img/wn/\(iconCode)@2x.png"
        let urlImage = URL(string: iconURL)!
        cell.weatherImage.downloaded(from: urlImage, contentMode: .scaleAspectFit)
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Mengambil data image icon dan object lainnya.
    func getIconAndData() {
        
        if let weather = weatherData {
            
            let iconCode = weather.icon
            let iconURL = "http://openweathermap.org/img/wn/\(iconCode)@2x.png"
            let urlImage = URL(string: iconURL)!
            weatherIconImage.downloaded(from: urlImage, contentMode: .scaleAspectFit)
            
            setDataInfo()
        }
    }
    
    func setDataInfo() {
        
        salamValue.text = getGreetingMessage()
        namaValue.text = weatherData?.name
        temperatureValue.text = weatherData?.temperatureString
        kondisiCuacaValue.text = weatherData?.conditionName
        namaKotaValue.text = weatherData?.cityName
    }
    
    
    // MARK: - Mengambil data 5 hari ke depan.
    func getData5HariKedepan() {
        
        if let weather = weatherData {
            
            let cityName = weather.cityName.changeCityName()
            let API_KEY = "3f27005d39bfad227d6540d4297209cd"
            let WEATHER_URL = "https://api.openweathermap.org/data/2.5/forecast?appid=\(API_KEY)&units=metric&q=\(cityName)&lang=id"
            
            AF.request(WEATHER_URL, method: .get).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    
                    let json = JSON(value)
                    if let listArray = json["list"].array {
                        
                        for listItem in listArray {
                            
                            let conditionId = listItem["weather"][0]["id"].intValue
                            let temp = listItem["main"]["temp"].doubleValue
                            let icon = listItem["weather"][0]["icon"].stringValue
                            
                            let timestamp = listItem["dt"].doubleValue
                            let date = self.convertTimestampToDateString(timestamp)
                            
                            let weatherFiveDays = FiveDaysModel(
                                conditionId: conditionId, temp: temp, icon: icon, date: date
                            )
                            self.fiveDaysModel.append(weatherFiveDays)
                            
                            DispatchQueue.main.async {
                                self.weatherTableView.reloadData()
                            }
                        }
                        
                    } else {
                        
                        print("Data tidak ditemukan.")
                    }
                    
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
    
    
    // MARK: - Function untuk mengatur format Date
    func convertTimestampToDateString(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter.string(from: date)
    }
    

    // MARK: - Function untuk menampilkan salam berdasarkan waktu
    func getGreetingMessage() -> String {
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 5..<12:
            return "Selamat Pagi"
        case 12..<15:
            return "Selamat Siang"
        case 15..<18:
            return "Selamat Sore"
        default:
            return "Selamat Malam"
        }
    }
    
    
    // MARK: - Function untuk mengubah tampilan object pada saat siang dan malam hari.
    func changeObject() {
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        if currentHour >= 5 && currentHour <= 18 {
            
            navigationController?.navigationBar.tintColor = UIColor.black
            
        } else {
            
            navigationController?.navigationBar.tintColor = UIColor.white
            
            salamValue.textColor = UIColor.white
            namaValue.textColor = UIColor.white
            kondisiCuacaValue.textColor = UIColor.white
            namaKotaValue.textColor = UIColor.white
            temperatureValue.textColor = UIColor.white
            celciusLabel.textColor = UIColor.white
            textPrakiraanLabel.textColor = UIColor.white
            
            backgroundImage.image = UIImage(named: "background-night")
        }
    }
  
}
