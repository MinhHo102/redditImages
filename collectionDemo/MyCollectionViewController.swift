//
//  MyCollectionViewController.swift
//  collectionDemo
//
//  Created by minh ho on 9/27/17.
//  Copyright © 2017 minh ho. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    
    //MARK: Private Variables
    //contains titles of urls obtained from parsing json, should be the names? might need to add .png to all of them.
    var titlesArray = [String]()
    //var urlsArray = [String]()
    var urlsArray = ["https://www.reddit.com/r/EarthPorn/comments/71lzef/join_other_redditors_traveling_to_washington_dc/", "https://i.redd.it/ybp6bv0b9upz.jpg", "https://i.redd.it/w7mvzief2wpz.jpg", "https://i.redd.it/rvhmimtjzqpz.jpg", "https://i.redd.it/1r8ycu15cspz.jpg", "https://i.redd.it/e7fav7ow3xpz.jpg", "https://i.redd.it/qm3qjqnqkupz.jpg", "https://i.redd.it/aanfpkbaaxpz.jpg", "https://i.redd.it/t9qyqhacqwpz.jpg", "https://i.redd.it/17bne1f1rwpz.jpg", "http://www.siddharthprem.com/Galleries/Greenland/i-qLZbFfN/0/4b8b6175/XL/IMG_0505-web-XL.jpg", "https://i.redd.it/lx8i66nvzwpz.jpg", "https://i.imgur.com/HA0jzr6.jpg", "https://imgur.com/Akoysyz", "https://i.redd.it/hlov4db70xpz.jpg", "https://imgur.com/R52r1ka", "https://i.redd.it/bddlmg8t3xpz.jpg", "https://i.imgur.com/cjWPe97.jpg", "https://i.imgur.com/F5a3avH.jpg", "https://i.redd.it/6senmrjalxpz.jpg", "https://i.redd.it/h74bjsyu7vpz.jpg"]
    var imageArray = [UIImage]()
    //MARK: Private Functions
    
    //Function to return json of given subreddit, parse urls, and add urls to private Array
    func getHttpRequest(UrlStringOfSubreddit: String){
        guard let url = URL(string: UrlStringOfSubreddit) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let data = data {
                    let json: [String:AnyObject]!
                    do
                    {
                        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    }
                    catch
                    {
                        return
                    }
                    
                    if let dataDic = json["data"] as? [String:AnyObject],
                        let dataArray = dataDic["children"] as? [[String:AnyObject]]{
                        for index in 0...20{
                            let url = dataArray[index]["data"]!["url"]! as! String
                            let title = dataArray[index]["data"]!["title"]! as! String
                            self.urlsArray.append(url)
                            self.titlesArray.append(title)
                        }
                        print(self.urlsArray)
                        print("\n")
                        print(self.titlesArray)
                    }
                    
                }
            }
        }
        task.resume()
    }
    //Function to create an image from a url, and then append to array of UIImages?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure images to be stored in a nsurlcache
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity, diskCapacity: "myDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)
        
//        var subReddit: String = "https://reddit.com/r/earthPorn/.json"
//        getHttpRequest(UrlStringOfSubreddit: subReddit)
//        gets rid of first url, which is some random ad promo on page
        //urlsArray.remove(at: 0)
        //calling above function will instantiate urlsArray to be an array of urls of images.
        //then must figure out how to turn urls into images.

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return urlsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
        
        let resource = ImageResource(downloadURL: URL(string: urlsArray[indexPath.row])!, cacheKey: urlsArray[indexPath.row])
        cell.imageView.kf.setImage(with: resource)
        return cell
    }



}
