
import UIKit

public class VKImageEditPreviewViewController: UIViewController {
    
    private struct Demensions {
        static let cellSize = CGSize.init(width: 60, height: 60)
        static let cellIntervel : CGFloat = 12
        static let thumbnailcollectionEdage = UIEdgeInsets.init(top: 12, left: 20, bottom: 20, right: -12)
        static let editButtonSize = CGSize.init(width: 80, height: 36)
        static let doneButtonSize = CGSize.init(width: 80, height: 36)
        static let bottomOffset : CGFloat = -35
        
        static let mainCollectionViewEdage = UIEdgeInsets.init(top: 20, left: 0, bottom: 20, right: 0)
        static let bottomViewAllHeight = Demensions.cellSize.height + Demensions.thumbnailcollectionEdage.top + Demensions.thumbnailcollectionEdage.bottom + Demensions.doneButtonSize.height - Demensions.bottomOffset
    }
    
    public weak var delegate:VKImagePickerControllerDelegate?
    
    public var imageList = [UIImage].init()
    
    var imageSelectList = [Bool].init()
    
    public var config = VKEditConfigure.init()
    
    var selectIndex = 0 {
        didSet{
            updateUIAfterSelectIndexChanged()
        }
    }
    
    lazy var rightBarItem:UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("1", for: .normal)
        button.addTarget(self, action: #selector(rightBarItemEvent(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomView:UIView = {
        let view = UIView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = Demensions.cellSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = Demensions.cellIntervel
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        let collection = UICollectionView.init(frame: CGRect.zero,collectionViewLayout: layout)
        
        collection.register(VKEditPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "VKEditPreviewCollectionViewCell")
        collection.alwaysBounceHorizontal = true
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var mainCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let topHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight
        let cellHeight = UIScreen.main.bounds.height - topHeight - Demensions.bottomViewAllHeight - Demensions.mainCollectionViewEdage.top - Demensions.mainCollectionViewEdage.bottom
        let width = UIScreen.main.bounds.width - Demensions.mainCollectionViewEdage.left - Demensions.mainCollectionViewEdage.right
        layout.itemSize = CGSize.init(width:width , height: cellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        let collection = UICollectionView.init(frame: CGRect.zero,collectionViewLayout: layout)
        
        collection.register(VKEditPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "VKEditPreviewCollectionViewCell")
        collection.alwaysBounceHorizontal = true
        
        collection.dataSource = self
        collection.isPagingEnabled = true
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var editButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var doneButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonClickEvent(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Initialization
    public required init(images:[UIImage],configure:VKEditConfigure = VKEditConfigure()) {
        super.init(nibName: nil, bundle: nil)
        imageList.append(contentsOf: images)
        config = configure
        
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}

// MARK:setup
extension VKImageEditPreviewViewController{
    func setup(){
        view.backgroundColor = UIColor.black
        modalPresentationStyle = .fullScreen
        for _ in 0..<imageList.count{
            imageSelectList.append(true)
        }
        setupNavigationBar()
        setupBottomView()
        setupMainCollectionView()
        thumbnailCollectionView.reloadData()
        mainCollectionView.reloadData()
    }
    
    func setupMainCollectionView(){
        view.addSubview(mainCollectionView)
        NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: Demensions.mainCollectionViewEdage.top),
            mainCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: Demensions.mainCollectionViewEdage.left),
            mainCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: Demensions.mainCollectionViewEdage.right),
            mainCollectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor,constant: -Demensions.mainCollectionViewEdage.bottom)
        ])
    }
    
    func setupNavigationBar(){
        
        navigationController?.navigationBar.barTintColor = config.topAndBottomViewBackgroundColor
        navigationController?.navigationBar.isTranslucent = false
        let left = UIBarButtonItem.init(image: nil, style: .plain, target: self, action: #selector(leftBarItemEvent(sender:)))
        switch config.backButton {
        case .image(let image):
            left.image = image?.scaleImageFit(with: 20)
            left.title = nil
        case .title(let title):
            left.title = title
            left.image = nil
        }
        left.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = left
        
        let right = UIBarButtonItem.init(customView: rightBarItem)
        
        rightBarItem.backgroundColor = config.controlsBackgroundColor
        rightBarItem.setTitleColor(config.controlsTitleColor, for: .normal)
        
        navigationItem.rightBarButtonItem = right
        
    }
    
    func setupBottomView(){
        view.addSubview(bottomView)
        bottomView.addSubview(thumbnailCollectionView)
        bottomView.addSubview(editButton)
        bottomView.addSubview(doneButton)
        bottomView.backgroundColor = config.topAndBottomViewBackgroundColor
        thumbnailCollectionView.backgroundColor = config.topAndBottomViewBackgroundColor
        editButton.setTitle(config.editImageTitle, for: .normal)
        editButton.setTitleColor(config.controlsTitleColor, for: .normal)
        doneButton.setTitle(config.doneTitle, for: .normal)
        doneButton.setTitleColor(config.controlsTitleColor, for: .normal)
        doneButton.backgroundColor = config.controlsBackgroundColor
        
        var bottomOffsetHeight = Demensions.bottomOffset
        if #available(iOS 11.0, *) {
            bottomOffsetHeight -=  view.safeAreaInsets.bottom
        }
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            thumbnailCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor,constant: Demensions.thumbnailcollectionEdage.top),
            thumbnailCollectionView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor,constant: Demensions.thumbnailcollectionEdage.left),
            thumbnailCollectionView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor,constant: Demensions.thumbnailcollectionEdage.right),
            thumbnailCollectionView.heightAnchor.constraint(equalToConstant: Demensions.cellSize.height),
            
            editButton.topAnchor.constraint(equalTo: thumbnailCollectionView.bottomAnchor,constant: Demensions.thumbnailcollectionEdage.bottom),
            editButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor,constant: Demensions.thumbnailcollectionEdage.left),
            editButton.heightAnchor.constraint(equalToConstant: Demensions.editButtonSize.height),
            editButton.widthAnchor.constraint(equalToConstant: Demensions.editButtonSize.width),
            
            doneButton.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor,constant: Demensions.thumbnailcollectionEdage.right),
            doneButton.heightAnchor.constraint(equalToConstant: Demensions.doneButtonSize.height),
            doneButton.widthAnchor.constraint(equalToConstant: Demensions.doneButtonSize.width),
            doneButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor,constant: bottomOffsetHeight)
        ])
    }
    
    func updateUIAfterSelectIndexChanged(){
        thumbnailCollectionView.reloadData()
        mainCollectionView.scrollToItem(at: IndexPath.init(row: selectIndex, section: 0), at: .centeredHorizontally, animated: false)
        updateRightBarItem(with: imageSelectList[selectIndex])
    }
    
    func updateRightBarItem(with isSelect:Bool){
        if isSelect{
            rightBarItem.setImage(nil, for: .normal)
            rightBarItem.setTitle("\(selectIndex+1)", for: .normal)
            rightBarItem.backgroundColor = config.controlsBackgroundColor
            
        }else{
            rightBarItem.setTitle(nil, for: .normal)
            
            rightBarItem.backgroundColor = UIColor.clear
            rightBarItem.setImage(UIImage.init(named: "unselected")!, for: .normal)
        }
    }
}

// MARK:UIScrollViewDelegate
extension VKImageEditPreviewViewController:UIScrollViewDelegate{
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(mainCollectionView){
            let offset = scrollView.contentOffset
            let index = Int(offset.x/mainCollectionView.frame.size.width)
            self.selectIndex = index
        }
    }
}

// MARK:UICollectionViewDataSource
extension VKImageEditPreviewViewController:UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VKEditPreviewCollectionViewCell", for: indexPath) as! VKEditPreviewCollectionViewCell
        let image = imageList[indexPath.row]
        cell.thumbnailImageView.image = image
        if !collectionView.isEqual(mainCollectionView){
            if indexPath.row == selectIndex{
                cell.thumbnailImageView.layer.borderColor = config.controlsBackgroundColor.cgColor
                cell.thumbnailImageView.layer.borderWidth = 2
            }else{
                cell.thumbnailImageView.layer.borderColor = config.controlsBackgroundColor.cgColor
                cell.thumbnailImageView.layer.borderWidth = 0
            }
        }
        return cell
    }
    
    
}

// MARK:UICollectionViewDelegate
extension VKImageEditPreviewViewController:UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(thumbnailCollectionView){
            selectIndex = indexPath.row
        }
    }
    
}


// MARK:Action methods
extension VKImageEditPreviewViewController{
    @objc func editButtonClick(){
        let image = imageList[selectIndex]
        let vc = VKImageEditViewController.init(image: image)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func doneButtonClickEvent(sender:UIButton){
        let imgs = imageList.filter {
            let index = imageList.firstIndex(of: $0)
            return imageSelectList[index!]
        }
        delegate?.didSelectDone(self, images: imgs)
    }
    
    @objc func rightBarItemEvent(sender:UIBarButtonItem){
        imageSelectList[selectIndex] = !imageSelectList[selectIndex]
        updateRightBarItem(with: imageSelectList[selectIndex])
    }
    
    @objc func leftBarItemEvent(sender:UIBarButtonItem){
        delegate?.didCancel(self)
    }
}

extension VKImageEditPreviewViewController:VKImagePickerControllerDelegate{
    public func didCancel(_ imagePicker: UIViewController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    public func didSelectDone(_ imagePicker: UIViewController, images: [UIImage]) {
        if imagePicker is VKImageEditViewController{
            guard let image = images.first else {return}
            self.imageList[selectIndex] = image
            self.mainCollectionView.reloadData()
            self.thumbnailCollectionView.reloadData()
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}
