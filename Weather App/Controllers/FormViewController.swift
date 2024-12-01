//
//  ViewController.swift
//  Weather App
//
//  Created by Muhamad Septian Nugraha on 29/11/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import iOSDropDown

class FormViewController: UIViewController {
    
    @IBOutlet weak var namaTextField: UITextField!
    @IBOutlet weak var provinsiTextField: DropDown!
    @IBOutlet weak var kotaTextField: DropDown!
    @IBOutlet weak var kotaLabel: UILabel!
    @IBOutlet weak var backgroundKotaImage: UIImageView!
    
    var provinsi: [ProvinsiModel] = []
    var kota: [KotaModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        getDataProvince()
        setObject()
    }
    
    
    // MARK: - Set Object
    func setObject() {
        
        provinsiTextField.arrowSize = 15
        provinsiTextField.arrowColor = .black
        provinsiTextField.textAlignment = .center
        provinsiTextField.selectedRowColor = UIColor.lightBlueCustom
        provinsiTextField.textColor = .black
                
        kotaTextField.arrowSize = 15
        kotaTextField.arrowColor = .black
        kotaTextField.textAlignment = .center
        kotaTextField.selectedRowColor = UIColor.lightBlueCustom
        kotaTextField.textColor = .black
 
        kotaTextField.isHidden = true
        kotaLabel.isHidden = true
        backgroundKotaImage.isHidden = true
    }
    

    // MARK: - Mengambil Data Provinsi dari API
    func getDataProvince() {
        
        let API_URL = "https://septianngha.github.io/api-wilayah-indonesia/api/provinces.json"
        
        checkInternetConnection { isConnected in
            if isConnected {
                
                AF.request(API_URL, method: .get).responseJSON { response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        let provinsiArray = json.arrayValue
                        
                        self.provinsi = provinsiArray.compactMap { data in
                            let id = data["id"].intValue
                            let name = data["name"].stringValue
                            return ProvinsiModel(id: id, name: name)
                        }
                        
                        DispatchQueue.main.async {
                            self.provinsiTextField.optionArray = self.provinsi.map { $0.name.capitalized }
                            self.provinsiTextField.didSelect{(selectedText , index ,id) in
                                
                            if let selectedProvince = self.provinsi.first(where: { $0.name.capitalized == selectedText }) {
                                    self.kotaTextField.isHidden = false
                                    self.kotaLabel.isHidden = false
                                    self.backgroundKotaImage.isHidden = false
                                
                                    self.getDataKota(idProvinsi: selectedProvince.id)
                                }
                                
                            }
                        }
                        
                    case .failure(let error):
                        print("Error fetching data: \(error)")
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                }
            }
        }
    }
    
    
    // MARK: - Mengambil Data Kota dari API
    func getDataKota(idProvinsi: Int) {
        
        kotaTextField.text = ""
        kotaTextField.selectedIndex = 0
        kotaTextField.optionArray = [""]
        
        let API_KOTA = "https://septianngha.github.io/api-wilayah-indonesia/api/regencies/\(idProvinsi).json"
        
        checkInternetConnection { isConnected in
            if isConnected {
                
                AF.request(API_KOTA, method: .get).responseJSON { response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        let kotaArray = json.arrayValue
                        
                        self.kota = kotaArray.compactMap { data in
                            let id = data["id"].intValue
                            let province_id = data["province_id"].intValue
                            let name = data["name"].stringValue
                            
                            return KotaModel(id: id, province_id: province_id, name: name)
                        }
                        
                        DispatchQueue.main.async {
                            
                            self.kotaTextField.optionArray = self.kota.map { $0.name.capitalized }
                        }
                        
                    case .failure(let error):
                        print("Error fetching data: \(error)")
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                }
            }
            
        }
    }
    
    
    // MARK: - Mengecek Data Cuaca dari API
    func checkAvaibilityData(cityName: String) {
        
        let API_KEY = "3f27005d39bfad227d6540d4297209cd"
        let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?appid=\(API_KEY)&units=metric&q=\(cityName)"
        
        checkInternetConnection { isConnected in
            if isConnected {
                
                AF.request(WEATHER_URL, method: .get).responseJSON { response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        let cod = json["cod"].intValue
                        let temp = json["main"]["temp"].doubleValue
                        let conditionId = json["weather"][0]["id"].intValue
                        let icon = json["weather"][0]["icon"].stringValue
                        let name = self.namaTextField.text ?? ""
                        let city = self.kotaTextField.text ?? ""
                        
                        let weatherModel = WeatherModel(name: name, cityName: city, temp: temp, conditionId: conditionId, icon: icon)
                        
                        if cod == 404 {
                            
                            let alert = UIAlertController(title: "Pemberitahuan", message: "Data API untuk kota yang di input tidak tersedia. Silakan masukkan nama kota lain.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                            self.present(alert, animated: true, completion: nil)
                        } else {
                            
                            self.performSegue(withIdentifier: "goToDetail", sender: weatherModel)
                        }

                    case .failure(let error):
                        print("Error fetching data: \(error)")
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.weatherData = sender as? WeatherModel
        }
    }
    
    
    // MARK: - Button Pressed
    @IBAction func buttonProsesPressed(_ sender: UIButton) {
        
        checkInternetConnection { isConnected in
            if isConnected {
                
                if let selectedKota = self.kotaTextField.text {
                    if let selectedKota = self.kota.first(where: { $0.name.capitalized == selectedKota }) {
                        
                        let cityName = selectedKota.name
                        let changedCityName = cityName.changeCityName()
                        
                        self.checkAvaibilityData(cityName: changedCityName)
                    }
                }
                
                if self.namaTextField.text?.isEmpty == true || self.provinsiTextField.text?.isEmpty == true || self.kotaTextField.text?.isEmpty == true {
                    
                    let alert = UIAlertController(title: "Pemberitahuan", message: "Data yang diinputkan belum lengkap. Silahkan lengkapi data input.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
            } else {
                    
                    DispatchQueue.main.async {
                        self.showNoInternetAlert()
                    }
                }
        }
    }
    
    
    // MARK: - Function yang digunakan untuk cek koneksi internet.
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        if let reachability = NetworkReachabilityManager(), reachability.isReachable {
            completion(true)
        } else {
            completion(false)
        }
    }

    
    // MARK: - Function yang dipanggil ketika koneksi internet bermasalah.
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "Koneksi Internet Bermasalah",
                                      message: "Pastikan perangkat Anda terhubung ke internet.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
