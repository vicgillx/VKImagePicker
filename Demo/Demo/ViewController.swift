

import UIKit
import VKImagePicker
class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images:[UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        // Do any additional setup after loading the view.
    }

    @IBAction func onButtonShowImagePicker(_ sender: Any) {
        let config = VKConfiguration()
        let vc : VKImagePickerViewController = VKImagePickerViewController.init(configuration: config)
        vc.delegate = self
        vc.imageLimit = 3
        vc.type = .onlyPhotoLib
        self.present(vc, animated: true, completion: nil)
    }
    
}
// MARK:VKImagePickerControllerDelegate
extension ViewController:VKImagePickerControllerDelegate{
    func didCancel(_ imagePicker: UIViewController) {
        imagePicker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didSelectDone(_ imagePicker: UIViewController, images: [UIImage]) {
        self.images = images
        imagePicker.presentingViewController?.dismiss(animated: true, completion: nil)
        self.collectionView.reloadData()
    }
}

extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCollectionViewCell", for: indexPath) as! DemoCollectionViewCell
        cell.contentImageView.image = images![indexPath.row]
        cell.contentImageView.contentMode = .scaleAspectFit
        return cell
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var heigth = UIScreen.main.bounds.height - 50
        if #available(iOS 13.0, *){
            heigth -= (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        }
        let size = CGSize.init(width: UIScreen.main.bounds.width, height: heigth)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


