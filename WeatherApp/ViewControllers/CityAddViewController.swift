//
//  CityAddViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import UIKit

class CityAddViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tasksTableView: UITableView!
    
    // MARK: - Properties
    private let citiesData = ["Ульяновск", "Москва", "Казань"]
    private var filteredData: [String]!
    private let citySearchCell = "citySearchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBar.delegate = self
        tasksTableView.dataSource = self
        
        filteredData = citiesData
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CityAddViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: citySearchCell, for: indexPath)
        var cellConfigurator = cell.defaultContentConfiguration()
        
        cellConfigurator.text = filteredData[indexPath.row]
        
        cell.contentConfiguration = cellConfigurator
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension CityAddViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = []
        
        if searchText.isEmpty {
            filteredData = citiesData
        } else {
            for city in citiesData {
                if city.lowercased().contains(searchText.lowercased()) {
                    filteredData?.append(city)
                }
            }
        }
        
        tasksTableView.reloadData()
    }
}
