//
//  CityAddViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import UIKit
import MapKit

class CityAddViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var citiesSearchTableView: UITableView!
    
    // MARK: - Properties
    private let storageManager = StorageManager.shared
    private let citySearchCell = "citySearchCell"
    weak var delegateCities: CitiesViewControllerDelegate?
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        citiesSearchTableView.dataSource = self
        citiesSearchTableView.delegate = self
        
        // Maps
        searchCompleter.delegate = self
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension CityAddViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
        citiesSearchTableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension CityAddViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        
        citiesSearchTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension CityAddViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: citySearchCell, for: indexPath)
        var cellConfigurator = cell.defaultContentConfiguration()
        
        let searchResult = searchResults[indexPath.row]
        cellConfigurator.text = searchResult.title
        
        cell.contentConfiguration = cellConfigurator
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CityAddViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let city = City(name: searchResults[indexPath.row].title)
        let _ = storageManager.addCity(city: city)

        delegateCities?.updateUI()
        dismiss(animated: true)
    }
}
