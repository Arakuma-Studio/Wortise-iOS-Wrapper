import UIKit
import Foundation
import WortiseSDK

class WortiseBanner
{
    var wortiseWrapper: WortiseWrapper?
    var onImpressionCall: UnityCallback?
    var onFailedToLoadCall: UnityCallback?
    var positionString: String! = ""
    var adString: String! = ""
    var refreshSeconds: Double!
    var paddingPx: Int32!
    var bannerView: BannerViewController?
    
    func Initialize(wortiseWrap: WortiseWrapper, adID: UnsafePointer<CChar>, bannerPosition: UnsafePointer<CChar>, refreshSecs: Double, onImpression: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback)
    {
        wortiseWrapper = wortiseWrap
        adString = String(cString: adID)
        positionString = String(cString: bannerPosition)
        refreshSeconds = refreshSecs
        onImpressionCall = onImpression
        onFailedToLoadCall = onFailedToLoad
    }
    
    func LoadAndShowAd(paddingPxFromBorder: Int32)
    {
        guard let wWrapper = wortiseWrapper else
        {
            NSLog("ERROR! Theres no wortise wrapper!!!!")
            return
        }
        
        paddingPx = paddingPxFromBorder
        bannerView = BannerViewController(bannerClass: self)
        
        guard let topView = wWrapper.GetTopViewController() else
        {
            NSLog("ERROR! Couldnt find top view for banner!!!!")
            return
        }
        
        if let bView = bannerView
        {
            topView.addChild(bView)
            bView.view.frame = topView.view.bounds
            topView.view.addSubview(bView.view)
            bView.didMove(toParent: topView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
            {
                bView.LoadBanner()
            }
        }
    }
        
    func IsBannerLoading() -> Int32
    {
        if let bView = bannerView
        {
            guard let bAd = bView.bannerAd else
            {
                return 1
            }
                
            if (bAd.isLoading)
            {
                return 1
            }
        }
        return 0
    }
        
    func DestroyBannerAd()
    {
        guard let bView = bannerView else
        {
            NSLog("There's no banner view to destroy")
            return
        }
            
        if bView.bannerAd != nil
        {
            bView.bannerAd.removeFromSuperview()
            bView.bannerAd.destroy()
            bView.bannerAd = nil
        }
            
        if bView.parent != nil
        {
            bView.willMove(toParent: nil)
            bView.view.removeFromSuperview()
            bView.removeFromParent()
        }
            
        bannerView = nil
    }
        
    func AdPixelHeight() -> Int32
    {
        guard let bView = bannerView else
        {
            return 0
        }
            
        return bView.AdPixelHeight()
    }
}
