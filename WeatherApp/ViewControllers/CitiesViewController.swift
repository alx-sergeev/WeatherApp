//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 24.01.2022.
//

import UIKit

// MARK: - Protocol delegate
protocol CitiesViewControllerDelegate: AnyObject {
    func updateUI()
}

class CitiesViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var citiesTableView: UITableView!
    
    // MARK: - Properties
    private let cityCell = "cityCell"
    private let segueToCityAdd = "segueToCityAdd"
    private let storageManager = StorageManager.shared
    private lazy var getCities: [City] = storageManager.getCities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueToCityAdd else { return }
        guard let cityAddVC = segue.destination as? CityAddViewController else { return }
        
        cityAddVC.delegateCities = self
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        if !citiesTableView.isEditing {
            citiesTableView.setEditing(true, animated: true)
        } else {
            citiesTableView.setEditing(false, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CitiesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cityCell, for: indexPath)
        var cellConfigurator = cell.defaultContentConfiguration()
        
        let city = getCities[indexPath.row]
        cellConfigurator.text = city.name
        
        cell.contentConfiguration = cellConfigurator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let _ = storageManager.deleteCity(at: indexPath.row)
            
            updateUI()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let currentCity = storageManager.deleteCity(at: sourceIndexPath.row) else { return }
                
        let _ = storageManager.addCity(city: currentCity, at: destinationIndexPath.row)
    }
}

// MARK: - UITableViewDelegate
extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

// MARK: - CitiesViewControllerDelegate
extension CitiesViewController: CitiesViewControllerDelegate {
    func updateUI() {
        getCities = storageManager.getCities()
        citiesTableView.reloadData()
    }
}
