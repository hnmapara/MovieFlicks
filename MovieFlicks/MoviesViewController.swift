//
//  MoviesViewController.swift
//  MovieFlicks
//
//  Created by Harshit Mapara on 10/16/16.
//  Copyright © 2016 Harshit Mapara. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var movies: [NSDictionary]?
    var endPoint: String!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        errorLabel.text = "Error"
        self.errorLabel.isHidden = true

        // Initialize a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(MoviesViewController.performNetworkRequest), for: UIControlEvents.valueChanged)
        
        // add refresh control to table view
        tableView.addSubview(self.refreshControl)
        performNetworkRequest()
    }
    
    func performNetworkRequest() {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        // Display HUD right before the request is made
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            //MBProgressHUD.hide(for: self.view, animated: true)
            //self.refreshControl.endRefreshing()
            
            //if ((error) != nil) {
            //    self.errorLabel.text = " Netowork Error"
            //    self.errorLabel.isHidden = false
            //    print("There was a network error")
            //}
            
            if let data = dataOrNil {
                //self.errorLabel.isHidden = true
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                //self.errorLabel.text = "No Data"
                //self.errorLabel.isHidden = false
                print("There was an error")
            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl:URL! = URL(string: baseUrl + posterPath)
            //cell.posterImageView.setImageWith(imageUrl!)
            let imageRequest = URLRequest(url: imageUrl)
            
            cell.posterImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                   if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                   } else {
                      print("Image was cached so just update the image")
                      cell.posterImageView.image = image
                   }
                }, failure: { (imageRequest, iresponse, error) in
                    print("image fetch error")
                })
        }
        
        
        
        cell.titleLabel.text = title
        cell.overViewLabel.text = overview
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
    }
    

}
