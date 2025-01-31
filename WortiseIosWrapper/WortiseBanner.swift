import UIKit
import Foundation
import WortiseSDK

class WortiseBanner
{
    var bannerAd: WABannerAd!
    var onImpressionCall: UnityCallback?
    var onFailedToLoadCall: UnityCallback?
    var rootView: UIViewController!
    var positionString: String! = ""
    
    func Initialize(wortiseWrap: WortiseWrapper, adID: UnsafePointer<CChar>, bannerPosition: UnsafePointer<CChar>, refreshSecs: Double, onImpression: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback)
    {
        let adString = String(cString: adID)
        positionString = String(cString: bannerPosition)
        
        bannerAd = WABannerAd()
        bannerAd.adUnitId = adString
        bannerAd.adSize = WAAdSize.height50
        
        rootView = wortiseWrap.GetTopViewController()
        bannerAd.rootViewController = rootView
        
        bannerAd.autoRefreshTime = refreshSecs
        bannerAd.translatesAutoresizingMaskIntoConstraints = false
        
        onImpressionCall = onImpression
        onFailedToLoadCall = onFailedToLoad
        
        bannerAd.delegate = self
    }
    
    func LoadAndShowAd(paddingPxFromBorder: Int32)
    {
        rootView.view.addSubview(bannerAd)
        var windowScale: Double = 0;
        
        if #available(iOS 13.0, *) {
            if let windowScene = rootView.view.window?.windowScene
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
        
        let paddingPoints: Double = Double(paddingPxFromBorder) / windowScale
        
        if (positionString == "TOP")
        {
            NSLayoutConstraint.activate([
                bannerAd.topAnchor.constraint(equalTo: rootView.view.topAnchor, constant: paddingPoints + 25),
                bannerAd.centerXAnchor.constraint(equalTo: rootView.view.safeAreaLayoutGuide.centerXAnchor),
            ])
        }
        else
        {
            NSLayoutConstraint.activate([
                bannerAd.bottomAnchor.constraint(equalTo: rootView.view.bottomAnchor, constant: -paddingPoints - 25),
                bannerAd.centerXAnchor.constraint(equalTo: rootView.view.safeAreaLayoutGuide.centerXAnchor),
            ])
        }
        
        bannerAd.loadAd()
    }
    
    func IsBannerLoading() -> Int32
    {
        if (bannerAd.isLoading)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
    
    func DestroyBannerAd()
    {
        if bannerAd != nil
        {
            bannerAd.removeFromSuperview()
            bannerAd.destroy()
            bannerAd = nil
        }
    }
    
    func AdPixelHeight() -> Int32
    {
        if #available(iOS 13.0, *) {
            guard let windowScene = rootView.view.window?.windowScene else
            {
                return 0
            }
            
            return Int32(ceil(Double(bannerAd.adHeight * windowScene.screen.scale)))
            
        } else
        {
            guard let keyWindow = UIApplication.shared.keyWindow else
            {
                return 0
            }
            
            return Int32(ceil(Double(bannerAd.adHeight * keyWindow.screen.scale)))
        }
    }
}

extension WortiseBanner : WABannerDelegate
{
    func didClick(bannerAd: WABannerAd)
    {
        
    }
    
    func didFailToLoad(bannerAd: WABannerAd, error: WAAdError)
    {
        onFailedToLoadCall?()
        NSLog(error.message)
    }
    
    func didImpress(bannerAd: WABannerAd)
    {
        onImpressionCall?()
    }
    
    func didLoad(bannerAd: WABannerAd)
    {
        
    }
}
