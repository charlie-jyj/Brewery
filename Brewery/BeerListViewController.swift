//
//  BeerListViewController.swift
//  Brewery
//
//  Created by UAPMobile on 2022/01/26.
//

import UIKit

class BeerListViewController: UITableViewController {
    
    var beerList = [Beer]()
    var dataTasks = [URLSessionTask]()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar
        title = "브루어리"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //UITableView 설정
        tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell")
        tableView.rowHeight = 150
        
        // preFetchDataSource
        tableView.prefetchDataSource = self
        
        self.fetchBeer(of: currentPage)
    }
}

// UITableView DataSource, Delegate
extension BeerListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard self.currentPage != 1 else { return }
        
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == self.currentPage {
                self.fetchBeer(of: self.currentPage)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as? BeerListCell else { return UITableViewCell() }
        cell.configure(with: self.beerList[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeer = self.beerList[indexPath.row]
        let detailViewController = BeerDetailViewController()
        detailViewController.beer = selectedBeer
        self.show(detailViewController, sender: nil)
    }
    
    
}

private extension BeerListViewController {
    func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              self.dataTasks.firstIndex(where: {$0.originalRequest?.url == url}) == nil else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let beerList = try? JSONDecoder().decode([Beer].self, from: data) else {
                print("ERROR: URLSession data task \(String(describing: error?.localizedDescription))")
                return }
            
            switch response.statusCode {
            case (200...299):
                self.beerList += beerList
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400...499):
                print("""
                    ERROR: CLIENT ERROR \(response.statusCode)
                    RESPONSE \(response)
                """)
            case (500...599):
                print("""
                    ERROR: SERVER ERROR \(response.statusCode)
                    RESPONSE \(response)
                """)
            default:
                print("""
                    ERROR: ERROR \(response.statusCode)
                    RESPONSE \(response)
                """)
            }
            
        }
        
        dataTask.resume()
        self.dataTasks.append(dataTask)
    }
}
