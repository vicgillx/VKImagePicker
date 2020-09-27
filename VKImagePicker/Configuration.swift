
import UIKit

public enum VKImageButtonType{
    case image(UIImage?)
    case title(String)
}


public class VKImageCameraConfiguration{
    //button、image.set
    public var photographImage = AssetManager.getImage("photograph")
    
    public var reverseCameraImage = AssetManager.getImage("backCamera")
    
    public var doneButtonDemensions = VKImageButtonType.title(AssetManager.getLocalString("done"))
    
    public var backButtonDemensions = VKImageButtonType.image(AssetManager.getImage("back"))
    
    //demensions
    public var backButtonSize = CGSize.init(width:20, height: 20)
    
    public var backButtonTopOffset : CGFloat = 18
    
    public var backButtonLeadingOffset :CGFloat = 12
    
    public var reverseCameraSize = CGSize.init(width: 30, height: 30)
    
    public var reverseCameraTrailingOffset : CGFloat = -12
    
    public var photoPreviewEdage = UIEdgeInsets.init(top: 20, left: 0, bottom: 12, right: 0)
    
    public var photographImageSize = CGSize.init(width: 60, height: 60)
    
    public var photographImageBottomOffset : CGFloat = 50
    
    public var capuredImageSize = CGSize.init(width: 35, height: 35)
    
    public var capuredImageLeadingOffset : CGFloat = 12
    
    public var doneButtonSize = CGSize.init(width: 60, height: 25)
    
    public var doneButtonTrailingOffset : CGFloat = -12
    
    
    //font,color
    public var doneButtonFont = UIFont.systemFont(ofSize: 15, weight: .medium)
    
    public var doneButtonTitleColor = UIColor.white
    
    public var backButtonFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    public var backButtonTitleColor = UIColor.white
    
    public var capuredCountLabelFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    
    public var capuredCountLabelTitleColor = UIColor.white
    
    public var backgroundColor = UIColor.black
    
    //title
    public var requestCameraPermissionMessage = AssetManager.getLocalString("requestCameraPermissionMessage")
    
    public var requestLibraryPermissionMessage = AssetManager.getLocalString("requestLibraryPermissionMessage")
    
    /* when the number of capured photo reaches a maximum,and the imageLimit > 1,will show this alert
    */
    public var capuredReachMaxAlert = AssetManager.getLocalString("capuredReachMaxAlert")
    
    public init(){}

}

public class VKEditConfigure{
    //color
    public var topAndBottomViewBackgroundColor = UIColor.init(red: 119.0/255.0, green: 136.0/255.0, blue: 153.0/255.0, alpha: 1)
    
    public var controlsBackgroundColor = UIColor.init(red: 67.0/255.0, green: 205.0/255.0, blue: 128.0/255.0, alpha: 1)
    
    public var controlsTitleColor = UIColor.white
    
    //title
    public var editImageTitle = AssetManager.getLocalString("edit")
    
    public var doneTitle = AssetManager.getLocalString("done")
    
    public enum EditType:String {
        case line = "drawLine"
        case size = "clip"
        case mosaic = "mosaic"
    }

    public var backButton = VKImageButtonType.image(AssetManager.getImage("back"))
    
    public var editList = [EditType.line,EditType.size,EditType.mosaic]
   
    public init(){}
    
}

public class VKAssetConfigure{
    public var backgroundColor = UIColor.white
    
    public var topAndBottomViewBackgroundColor = UIColor.gray
    
    public var backButtonTitle = AssetManager.getLocalString("cancel")
    
    public var previewButtonTitle = AssetManager.getLocalString("preview")
    
    public var doneButtonTitle = AssetManager.getLocalString("done")
    
    public var reachMaxAlert = AssetManager.getLocalString("reachMaxAssetAlert")
    
}


 public class VKConfiguration{
    
    public var backgroundColor = UIColor.black

    public var cameraConfigure = VKImageCameraConfiguration()
    
    public var editConfigure = VKEditConfigure()
    
    public var assetConfigure = VKAssetConfigure()
    
    public var topAndBottomViewBackgroundColor = UIColor.init(red: 119.0/255.0, green: 136.0/255.0, blue: 153.0/255.0, alpha: 1)
    
    public init(){
        editConfigure.topAndBottomViewBackgroundColor = self.topAndBottomViewBackgroundColor
        assetConfigure.topAndBottomViewBackgroundColor = self.topAndBottomViewBackgroundColor
    }
}
