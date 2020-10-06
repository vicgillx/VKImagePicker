
import UIKit

let statusHeight :CGFloat = {
    var height:CGFloat = 0
    if #available(iOS 13.0, *) {
         height = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    } else {
        height = UIApplication.shared.statusBarFrame.height
    }
    return height
}()



public class VKImageEditViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private struct Demension{
        static let bottomOffset:CGFloat = -20
        static let trailingOffset:CGFloat = -12
        static let suerButtonSize = CGSize.init(width: 80, height: 40)
        static let toolEdage = UIEdgeInsets.init(top: -35, left: 25, bottom: 0, right: 20)
        static let subEdage = UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: -12)
        static let backTopOffset:CGFloat = statusHeight + 20
        static let backLeadingOffset:CGFloat = 12
        static let totalBottomViewHeight:CGFloat = 200
        static let revokeSize = CGSize.init(width: 25, height: 20)
    }
    
    public var editImage  = UIImage.init()
    
    private var originImage = UIImage.init()
    
    public weak var delegate:VKImagePickerControllerDelegate?
    
    let scrollView:UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .black
        scrollView.isScrollEnabled = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        return scrollView
    }()
    
    let contentView = UIView.init()
    
    lazy var imageView:VKDrawImgeView = {
        let imageView = VKDrawImgeView.init(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.red.cgColor
        imageView.drawDelegate = self
        return imageView
    }()
    
    let backButton :UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(AssetManager.getImage("retake"), for: .normal)
        button.addTarget(self, action: #selector(leftBarItemBackEvent(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomBackgroundView:UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bottomViewBottomConstraint:NSLayoutConstraint?
    
    lazy var toolCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: EditCollectionViewCellMaxWidth, height: EditCollectionViewCellMaxWidth)
        
        layout.minimumInteritemSpacing = 15
        let collectionview = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionview.register(VKImageEditCollectionViewCell.self, forCellWithReuseIdentifier: "VKImageEditCollectionViewCell")
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor.clear
        collectionview.delegate = self
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        return collectionview
    }()
    
    lazy var subCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: EditCollectionViewCellMinWidth, height: EditCollectionViewCellMinWidth)
        layout.minimumInteritemSpacing = 8
        
        let collectionview = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionview.register(VKImageEditCollectionViewCell.self, forCellWithReuseIdentifier: "VKImageEditCollectionViewCell")
        collectionview.backgroundColor = UIColor.clear
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.isHidden = true
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        return collectionview
    }()
    
    lazy var revokeButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(AssetManager.getImage("revoke"), for: .normal)
        button.setImage(AssetManager.getImage("revoke_disable"), for: .disabled)
        button.isHidden = true
        button.addTarget(self, action: #selector(revokeDrawImage), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var sureButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = self.config.controlsBackgroundColor
        button.setTitle(self.config.doneTitle, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sureButtonClick), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public var config = VKEditConfigure.init()
    
    public var currentEditType:VKEditConfigure.EditType = .line
    
    var selectToolIndex:IndexPath?
    var selectColorIndex:IndexPath?

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    // MARK: - Initialization
    public required init(image:UIImage,config:VKEditConfigure = VKEditConfigure.init()) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        editImage = image
        originImage = image
        self.config = config
        
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .fullScreen
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

// MARK:setup
extension VKImageEditViewController{

    
    func setup(){
        view.backgroundColor = UIColor.white
        modalPresentationStyle = .fullScreen
        setupSubViews()
    }
    
    func setupGuestrue(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.scrollView.panGestureRecognizer.require(toFail: pan)
    }
    

    
    func setupSubViews(){
        view.addSubview(scrollView)
        scrollView.delegate = self

        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        
        scrollView.frame = view.frame
        contentView.frame = scrollView.frame
        imageView.frame = contentView.bounds
        
        imageView.image = editImage
        
        resetupScrollContentFrame()
        
        view.addSubview(backButton)
        backButton.frame = CGRect.init(x:statusHeight+20 , y: 12, width: 25, height: 25)
        
        view.addSubview(bottomBackgroundView)
        bottomBackgroundView.addSubview(toolCollectionView)
        bottomBackgroundView.addSubview(subCollectionView)
        bottomBackgroundView.addSubview(sureButton)
        bottomBackgroundView.addSubview(revokeButton)

        bottomViewBottomConstraint = bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant:Demension.backTopOffset ),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Demension.backLeadingOffset),
            backButton.widthAnchor.constraint(equalToConstant: 25),
            backButton.heightAnchor.constraint(equalToConstant: 25),
            
            bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: Demension.totalBottomViewHeight),
            
            sureButton.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: Demension.bottomOffset),
            sureButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: Demension.trailingOffset),
            sureButton.widthAnchor.constraint(equalToConstant: Demension.suerButtonSize.width),
            sureButton.heightAnchor.constraint(equalToConstant: Demension.suerButtonSize.height),
            
            toolCollectionView.centerYAnchor.constraint(equalTo: sureButton.centerYAnchor),
            toolCollectionView.heightAnchor.constraint(equalToConstant: EditCollectionViewCellMaxWidth),
            toolCollectionView.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: Demension.toolEdage.left),
            toolCollectionView.trailingAnchor.constraint(equalTo: sureButton.leadingAnchor, constant: Demension.toolEdage.right),
            
            revokeButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor,constant: Demension.subEdage.right),
            revokeButton.bottomAnchor.constraint(equalTo: toolCollectionView.topAnchor, constant: Demension.toolEdage.top),
            revokeButton.widthAnchor.constraint(equalToConstant: Demension.revokeSize.width),
            revokeButton.heightAnchor.constraint(equalToConstant: Demension.revokeSize.height),
            
            
            subCollectionView.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: Demension.subEdage.left),
            subCollectionView.trailingAnchor.constraint(equalTo: revokeButton.leadingAnchor, constant: Demension.subEdage.right),
            subCollectionView.heightAnchor.constraint(equalToConstant: EditCollectionViewCellMaxWidth),
            subCollectionView.centerYAnchor.constraint(equalTo: revokeButton.centerYAnchor)
        ])
    }
    

    
    func resetupScrollContentFrame(){
        scrollView.zoomScale = 1
        imageView.frame = imageView.contentClippingRect
    }
    
    func setupSubViewLayout(){
        scrollView.addFillConstraint(in:view,insets:UIEdgeInsets.zero)
        contentView.addFillConstraint(in:scrollView,insets:UIEdgeInsets.zero)
    }
}

// MARK:UIScrollViewDelegate
extension VKImageEditViewController:UIScrollViewDelegate{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        self.contentView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

// MARK:Action methods
extension VKImageEditViewController{
    @objc func leftBarItemBackEvent(sender:UIButton){
        delegate?.didCancel(self)
    }
    
    @objc func drawAction(_ sender:UIPanGestureRecognizer){
       // imageView.isCanDraw = true
    }
    
    @objc func sureButtonClick(){
        guard let image = imageView.screenShot else {return}
        delegate?.didSelectDone(self, images: [image])
    }
    
    @objc func revokeDrawImage(){
        imageView.revokeLastDraw()
    }
}

// MAKR:DrawImageViewDelegate
extension VKImageEditViewController:DrawImageViewDelegate{
    func didStartDraw() {
        updateBottomView(isEdit: true)
    }
    
    func shouldStopDraw() {
        updateBottomView(isEdit: false)
    }
    
    func drawColorLineDidChange(_ currentLines: [CAShapeLayer]?) {
        revokeButton.isEnabled = currentLines?.count ?? 0 > 0
    }
    
    
}


fileprivate let drawLineColors:[UIColor] = [.white,.black,.red,.yellow,.green,.blue,.purple]
// MARK:UICollectionViewDataSource,UICollectionViewDelegate
extension VKImageEditViewController:UICollectionViewDataSource, UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(toolCollectionView){
            return config.editList.count
        }else{
            return drawLineColors.count
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VKImageEditCollectionViewCell", for: indexPath) as! VKImageEditCollectionViewCell
        if collectionView.isEqual(toolCollectionView){
            cell.circleView.isHidden = true
            cell.contentImageView.isHidden = false
            let image = AssetManager.getImage(config.editList[indexPath.row].rawValue)
            cell.contentImageView.image = image.withRenderingMode(.alwaysTemplate)
            if selectToolIndex == indexPath{
                cell.contentImageView.tintColor = UIColor.green
            }else{
                cell.contentImageView.tintColor = UIColor.white
            }

        }else{
            if currentEditType == .line{
                cell.circleView.isHidden = false
                cell.contentImageView.isHidden = true
                cell.circleView.backgroundColor = drawLineColors[indexPath.row]
                if selectColorIndex == indexPath{
                    cell.circleView.layer.borderWidth = 3
                }else{
                    cell.circleView.layer.borderWidth = 1
                }
            }else{
                cell.contentImageView.isHidden = false
                cell.contentView.isHidden = true
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(toolCollectionView){
            if  selectToolIndex == indexPath{
                selectToolIndex = nil
            }else{
                selectToolIndex = indexPath
            }
            let isEditing = selectToolIndex == indexPath
            subCollectionView.isHidden = (!isEditing || (config.editList[indexPath.row] == .size))
            revokeButton.isHidden = (!isEditing || config.editList[indexPath.row] == .size)
            if isEditing{
                switch config.editList[indexPath.row] {
                case .line:
                    imageView.type = .line
                    revokeButton.isEnabled = imageView.drawColorLayers.count > 0
                case .mosaic:
                    subCollectionView.isHidden = true
                    revokeButton.isEnabled = imageView.mosicMaskLayers.count > 0
                    imageView.prepareMosica { (finish) in
                        
                    }
                case .size:
                    print("origin size = \(originImage.size)")
                    guard let screenShot = imageView.screenShot else {return}
                    let clipView = VKEditImageClipView.init(image: screenShot) { (image) in
                        self.imageView.image = image
                        self.imageView.frame = self.imageView.contentClippingRect
                    }
                    view.addSubview(clipView)
                }
            }else{
                imageView.type = .none
            }
        }else{
            selectColorIndex = indexPath
            if let toolIndex = selectToolIndex{
                switch config.editList[toolIndex.row] {
                case .line:
                    let color = drawLineColors[indexPath.row]
                    self.imageView.drawColor = color
                default:
                    break
                }
            }
        }
        collectionView.reloadData()
    }
    
    func updateBottomView(isEdit:Bool){
        if isEdit{
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomBackgroundView.transform = self.bottomBackgroundView.transform.translatedBy(x: 0, y: Demension.totalBottomViewHeight)
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomBackgroundView.transform = .identity
            })
        }
    }
}


