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
}

// MARK: - CitiesViewControllerDelegate
extension CitiesViewController: CitiesViewControllerDelegate {
    func updateUI() {
        getCities = storageManager.getCities()
        citiesTableView.reloadData()
    }
}
