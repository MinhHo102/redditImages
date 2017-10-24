//
//  MyCollectionViewController.swift
//  collectionDemo
//
//  Created by minh ho on 9/27/17.
//  Copyright © 2017 minh ho. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
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
//NOTES: for images not showing up cuz adding extension doesnt work, need scraping etc, just delete from array before putting in collectionview
private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var myCollectionView: UICollectionView!
    var subRedditString = String()
    @IBAction func goBackToSearch(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Private Variables
    
    var titlesArray = [String]()
    var urlsArray = [String]()
    var urlsThumbnail = [String]()

    
    //MARK: Private Functions

    
    /*
     Sometimes urls doesn't end with an image extension, leaving image blanked when setting it as a view.
     Solution is to use inout which is basically pass by reference. We pass urlsArray into function, and allows us to look at
     urls as variables instead of constants
     */
    func addExtensionToUrls(urls: inout [String]){
//        print(urls.count)
//        print("\n")
        for i in 0..<urls.count {
            if !(urls[i].contains(".jpg") || urls[i].contains(".png")) {
                urls[i].append(contentsOf: ".jpg")
            }
        }
    }
    //Function to count number of flickr urls and other unwanted urls.
    func countFlickrUrls(urls: inout [String]) -> Int{
        var c:Int = 0
        for i in 0..<urls.count {
            if ((urls[i].contains("flickr.com") || (urls[i].contains("gfycat")) || (urls[i].contains("/.jpg")) || (urls[i].contains("gif")) || (urls[i].contains("/a/")))){
                c += 1
            }
        }
        return c
    }
    //Function to remove flickr images from array so they dont come up empty in view
    
    func removeFlickrUrls(urls: inout [String], newCount: Int){
        for i in 0..<newCount {
            if ((urls[i].contains("flickr.com") || (urls[i].contains("gfycat")) || (urls[i].contains("/.jpg")) || (urls[i].contains("gif")) || (urls[i].contains("/a/")))) {
                urls.remove(at: i)
            }
        }
    }
    //Fuction to swipe left from edge and go backwards from collectionView to UIText
    func swipeRight(recognizer: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "SegueCollectionBack", sender: self)
    }

    
    //Function to return json of given subreddit, parse for urls, and add urls to Array of Strings
    func getHttpRequest(UrlStringOfSubreddit: String, completion: @escaping (Bool, Any?, Error?)->Void){
        
//        var titlesArray = [String]()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
        var urls = [String]()
//        var urlsThumbnail = [String]()
        guard let url = URL(string: UrlStringOfSubreddit) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let data = data {
                    let json: [String:AnyObject]!
                    do
                    {
                        json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
                    }
                    catch
                    {
                        return
                    }
                    
                    if let dataDic = json["data"] as? [String:AnyObject],
                        let dataArray = dataDic["children"] as? [[String:AnyObject]]{
                        for i in 0...99{
                            let url = dataArray[i]["data"]!["url"]! as! String
//                            let title = dataArray[index]["data"]!["title"]! as! String
                            let thumbnail_url = dataArray[i]["data"]!["thumbnail"]! as! String
                            self.urlsThumbnail.append(thumbnail_url)
                            urls.append(url)
//                            self.titlesArray.append(title)
                        }
                        completion(true, urls, nil)
//                        print(self.titlesArray)
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
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector((swipeRight)))
        recognizer.direction = .right
        view.addGestureRecognizer(recognizer)
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
//        URLCache.shared = urlCache
//      self.collectionView?.delegate = self ; dont need since we did it in storyboard.
        //get rid of spaces at end, usually adds space on iphone after selecting a word.
//        subRedditString = subRedditString.trimmingCharacters(in: .whitespaces)
        subRedditString.replacingOccurrences(of: " ", with: "")
        let UrlStringOfSubreddit = "https://reddit.com/r/" + subRedditString + "/.json?limit=100"
            self.getHttpRequest(UrlStringOfSubreddit: UrlStringOfSubreddit) { (success, response, error) in
            if success {
                guard let urls = response as? [String] else {return}
                self.urlsArray = urls
                print(self.urlsThumbnail.count)
                print("\n")
                print(self.urlsArray.count)
                self.addExtensionToUrls(urls: &self.urlsArray)
                let newCount = self.urlsArray.count - self.countFlickrUrls(urls: &self.urlsArray)
                self.removeFlickrUrls(urls: &self.urlsArray, newCount: newCount)
                print("\n")
                print(self.urlsArray.count)
            } else if let error = error {
                print("Http request error: ", error)
            }
            
                DispatchQueue.main.async {
//                    print(self.urlsArray)
                    self.myCollectionView.reloadData()
                }
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("OMG YOU GOT MEMORY ERRORS WTF")
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
        
//        let resource = ImageResource(downloadURL: URL(string: urlsArray[indexPath.row])!, cacheKey: urlsArray[indexPath.row])
        //add second parameter specifying placeholder picture
//        cell.imageView.sd_setImage(with: URL(string: urlsArray[indexPath.row]) )
//        cell.imageView.sd_setImage(with: URL(string: urlsThumbnail[indexPath.row]) )
        
        cell.imageView.sd_setImage(with: URL(string: urlsThumbnail[indexPath.row]), placeholderImage: UIImage(named: "Placeholder.png"))

//        cell.imageView.kf.indicatorType = .activity
//        cell.imageView.kf.setImage(with: resource)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = (availableWidth) / 3
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 20.0
//        layout.minimumInteritemSpacing = 20.0
        return CGSize(width: widthPerItem-2.5, height: widthPerItem-2.5)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //TODO: add another segue to allow viewing individual images bigger with horizontal scrolling, add info?-title-etc
    //find a way to get more json, currently we only get 25 urls... as user scrolls down, scroll up refreshes. gesture recognizers, swipe down, get more urls, swipe up, refresh.
    //autocomplete subreddit uitextfield, error case doesnt exist.
    //currently /a/ and /.jpg not working for getting rid of urls with those substrings
    //also change this: get urls of both images and thumbnails, display latter in collectionview, display full image when touches one at a time. memory usage
    /*
     ok so what ive done. added thumbnail array; collectionview looks and displays these values now, they always come back as .jpg, so dont need to parse bad links like before, but for later implementation, if u want to enlarge the picture, we'll get from array of urls not thumbnail, and if we parse, we'll mismatch/unshow photos and thumbnails, so i propose we dont parse, and if it fails to display cuz of non image extension, then we display a default blank image. Code looks messy. Also i added more pictures by setting limit to 100 images at a time.
     */
}
