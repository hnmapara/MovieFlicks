//
//  DetailViewController.swift
//  MovieFlicks
//
//  Created by Harshit Mapara on 10/16/16.
//  Copyright © 2016 Harshit Mapara. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        print(movie)
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        if let posterPath = movie["poster_path"] as? String {
            let baseUrlHigh = "http://image.tmdb.org/t/p/original"
            let baseUrlLow = "http://image.tmdb.org/t/p/w45"
            
            let imageUrlHigh:URL! = URL(string: baseUrlHigh + posterPath)
            let imageUrlLow:URL! = URL(string: baseUrlLow + posterPath)
            
            let imageRequestHigh = URLRequest(url: imageUrlHigh)
            let imageRequestLow = URLRequest(url: imageUrlLow)
            
            //posterImageView.setImageWith(imageUrl!)
            
            self.posterImageView.setImageWith(imageRequestLow, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) in
                    if smallImageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = smallImage
                                                
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            
                            self.posterImageView.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in
                                
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                self.posterImageView.setImageWith(
                                    imageRequestHigh,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        
                                        self.posterImageView.image = largeImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in
                                        // do something for the failure condition of the large image request
                                        // possibly setting the ImageView's image to a default image
                                })
                        })
                        
                        
                        
                    } else {
                        print("Image was cached so just update the image")
                        self.posterImageView.image = smallImage
                    }
                },
                failure: { (imageRequest, iresponse, error) in
                    print("image fetch error")
                })
        }
        titleLable.text = title
        overViewLabel.text = overview
        overViewLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
