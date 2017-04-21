//
//  IRGameListViewController.swift
//  iRullo
//
//  Created by formador on 7/4/17.
//  Copyright © 2017 formador. All rights reserved.
//

import UIKit
import CoreData

class IRGameListViewController: UIViewController {
    
    //MARK: - Variables locales
    var manageContext : NSManagedObjectContext?
    var listGames = [Game]()
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var myFilterSegmentControll: UISegmentedControl!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    //MARK: - IBACTIONS
    @IBAction func filterChangeACTION(_ sender: Any) {
        //Code
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.alwaysBounceVertical = true
        
        // Do any additional setup after loading the view.
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

}//TODO: - FIN DE LA CLASE

extension IRGameListViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listGames.count == 0{
            let imageBackground = UIImageView(image: #imageLiteral(resourceName: "img_empty_list"))
            imageBackground.contentMode = .scaleAspectFit
            myCollectionView.backgroundView = imageBackground
        }else{
            myCollectionView.backgroundView = UIView()
        }
        return listGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! IRDetailCustomCell
        
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editGameSegue", sender: self)
    }
    
    
    
    
    
    
    
    
    
}











