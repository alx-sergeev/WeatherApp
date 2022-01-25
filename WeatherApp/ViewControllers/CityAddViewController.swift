//
//  CityAddViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import UIKit

class CityAddViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
