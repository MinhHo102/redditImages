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
import Alamofire
import SwiftyJSON

//struct ImageCell: Decodable {
//    let title: String
//    let imageUrl: String
//    let subreddit: String
//
//    init(json: [String:AnyObject]) {
//        title = json["title"] as? String ?? ""
//        imageUrl = json["url"] as? String ?? ""
//        subreddit = json["subreddit"] as? String ?? ""
//    }
//}
private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var myCollectionView: UICollectionView!
    
//    let queue = DispatchQueue(label: "MyDispatchQueueLabel")
    
    
    //MARK: Private Variables
    
    var titlesArray = [String]()
    var urlsArray = [String]()
    //var urlsArray = ["https://i.redd.it/ywtk0y0e3oqz.jpg", "https://i.redd.it/y36cnr2ymoqz.jpg", "https://i.redd.it/ut1mgyvq2lqz.jpg", "https://i.imgur.com/j6KWkym.jpg", "https://i.redd.it/ruqhcte17mqz.jpg", "https://i.redd.it/b192zb3uxjqz.jpg", "https://i.redd.it/530n6c0dimqz.jpg", "http://imgur.com/eGDCVQn", "https://i.redd.it/1eacu94henqz.jpg", "https://i.imgur.com/HLzeMOX.jpg", "https://i.redd.it/qbh9m4gv4pqz.jpg", "https://i.redd.it/fefy1lkzhmqz.jpg", "https://i.redd.it/m0hrdv23nnqz.jpg", "https://www.flickr.com/photos/dornoforpyro/36762558663/", "https://i.redd.it/oriees47rmqz.jpg", "https://i.redd.it/dh4dilocboqz.jpg", "https://i.imgur.com/n6RlwaY.jpg", "https://i.redd.it/5bfkitt8sjqz.jpg", "https://i.redd.it/2496huds6qqz.jpg", "http://www.roadaddiction.com/wp-content/uploads/2017/10/DSC01948b.jpg", "https://i.redd.it/f21mzipf7nqz.jpg"]

    
    //MARK: Private Functions

    
    //Function to return json of given subreddit, parse urls, and add urls to private Array
    func getHttpRequest(UrlStringOfSubreddit: String, completion: @escaping (Bool, Any?, Error?)->Void){
        
//        var titlesArray = [String]()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
        var urls = [String]()
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
//                            let title = dataArray[index]["data"]!["title"]! as! String
                            urls.append(url)
//                            self.titlesArray.append(title)
                            
                            
                        }
//                        print(self.urlsArray)
                        print("\n")
//                        print(self.titlesArray)
                        completion(true, urls, nil)
                    }
                    
                }
            }
        }
        
        task.resume()
        
    }
        
}

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configure images to be stored in a urlcache
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
//        URLCache.shared = urlCache
        
//        self.collectionView?.delegate = self
        DispatchQueue.global().async{
        let UrlStringOfSubreddit = "https://reddit.com/r/earthPorn/.json"
            self.getHttpRequest(UrlStringOfSubreddit: UrlStringOfSubreddit) { (success, response, error) in
            if success {
                guard let urls = response as? [String] else {return}
//                print("HELLO")
                self.urlsArray = urls
//                self.myCollectionView.reloadData()
                print(self.urlsArray)
            } else if let error = error {
                print(error)
            }
            
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
            }
        }

    //    urlsArray.remove(at: 0)
  
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = (availableWidth) / 3
        return CGSize(width: widthPerItem-2.5, height: widthPerItem-2.5)
    }

}
