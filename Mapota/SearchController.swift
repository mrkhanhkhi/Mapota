//
//  SearchController.swift
//  Mapota
//
//  Created by Vinh The on 10/13/16.
//  Copyright © 2016 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import MapKit

protocol SearchProtocol : class {
    func mkMapItem(mkMapItem : MKMapItem, checkPoint : Bool)
}

class SearchController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    weak var searchDelegate : SearchProtocol?
    var region : MKCoordinateRegion?
    var addressResult : [MKMapItem] = []
    var checkPoint : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        mySearchBar.delegate = self
        mySearchBar.placeholder = "Input Location Here !"
        mySearchBar.searchBarStyle = .minimal
        // Do any additional setup after loading the view.
        addGestureToTableView()
    }
    
    func addGestureToTableView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(resignFirstResponderSearchBar(sender:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func resignFirstResponderSearchBar(sender : UIGestureRecognizer) {
        mySearchBar.resignFirstResponder()
    }
    
    func updateSearchResult(searchText : String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = region!
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }else{
                self.addressResult = response!.mapItems
                self.myTableView.reloadData()
            }
            
        }
    }

}

extension SearchController : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !mySearchBar.resignFirstResponder(){
            if (touch.view?.isDescendant(of: myTableView))! {
                return false
            }
        }
        return true
    }
}

extension SearchController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressResult.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mapItem = addressResult[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.phoneNumber
        return cell
    }
    
}

extension SearchController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mkMapItem = addressResult[indexPath.row]
        searchDelegate?.mkMapItem(mkMapItem: mkMapItem, checkPoint: checkPoint!)
        navigationController?.popViewController(animated: true)
    }
    
}

extension SearchController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            addressResult.removeAll()
            myTableView.reloadData()
        }else{
            updateSearchResult(searchText: searchText)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("did begin editing")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("did end editing")
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked : \(searchBar.text)")
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel button")
    }
    
}
