import UIKit
import WortiseSDK
import Foundation

class PassthroughView : UIView
{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}

class BannerViewController : UIViewController
{
    var bannerAd: WABannerAd!
    var wBanner : WortiseBanner
    
    init(bannerClass : WortiseBanner)
    {
        wBanner = bannerClass
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view = PassthroughView()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.clear
        
        bannerAd = WABannerAd()
        bannerAd.adUnitId = self.wBanner.adString
        bannerAd.adSize = WAAdSize.height50
        bannerAd.rootViewController = self
        bannerAd.delegate = self
        bannerAd.autoRefreshTime = self.wBanner.refreshSeconds
        bannerAd.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func LoadBanner()
    {
        view.addSubview(bannerAd)
        var windowScale: Double = 0;
        
        if #available(iOS 13.0, *) {
            if let windowScene = view.window?.windowScene
            {
                windowScale = windowScene.screen.scale
            }
        }
        else
        {
            if let keyWindow = UIApplication.shared.keyWindow
            {
                windowScale = keyWindow.screen.scale
            }
        }
        
        let paddingPoints: Double = Double(wBanner.paddingPx) / windowScale
        
        if (wBanner.positionString == "TOP")
        {
            NSLayoutConstraint.activate([
                bannerAd.topAnchor.constraint(equalTo: view.topAnchor, constant: paddingPoints + 25),
                bannerAd.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            ])
        }
        else
        {
            NSLayoutConstraint.activate([
                bannerAd.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -paddingPoints - 25),
                bannerAd.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            ])
        }
        
        bannerAd.loadAd()
    }
    
    func AdPixelHeight() -> Int32
    {
        guard let bAd = bannerAd else
        {
            return 0
        }
        
        if #available(iOS 13.0, *) {
            guard let windowScene = view.window?.windowScene else
            {
                return 0
            }
            
            return Int32(ceil(Double(bAd.adHeight * windowScene.screen.scale)))
            
        } else
        {
            guard let keyWindow = UIApplication.shared.keyWindow else
            {
                return 0
            }
            
            return Int32(ceil(Double(bAd.adHeight * keyWindow.screen.scale)))
        }
    }
}

extension BannerViewController : WABannerDelegate
{
    func didClick(bannerAd: WABannerAd)
    {
        
    }
    
    func didFailToLoad(bannerAd: WABannerAd, error: WAAdError)
    {
        wBanner.onFailedToLoadCall?()
        NSLog(error.message)
    }
    
    func didImpress(bannerAd: WABannerAd)
    {
        wBanner.onImpressionCall?()
    }
    
    func didLoad(bannerAd: WABannerAd)
    {
        
    }
}
