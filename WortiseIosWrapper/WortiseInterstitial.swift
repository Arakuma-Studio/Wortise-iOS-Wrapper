import Foundation
import WortiseSDK
import UIKit

class WortiseInterstitial
{
    var interstitialAd: WAInterstitialAd!
    var onLoadedCall: UnityCallback?
    var onFailedToLoadCall: UnityCallback?
    var onFailedToShowCall: UnityCallback?
    var onDismissedCall: UnityCallback?
    var dummyView: UIViewController!
    
    func LoadInterstitialAd(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onFailedToShow: @escaping UnityCallback, onDismissed: @escaping UnityCallback)
    {
        if (interstitialAd != nil)
        {
            interstitialAd.destroy()
            interstitialAd = nil
        }
        
        let adIdString = String(cString: adID)
        interstitialAd = WAInterstitialAd(adUnitId: adIdString)
        onLoadedCall = onLoaded
        onFailedToLoadCall = onFailedToLoad
        onFailedToShowCall = onFailedToShow
        onDismissedCall = onDismissed
        interstitialAd.delegate = self
        interstitialAd.loadAd()
    }
    
    func ShowInterstitial(wortiseWrapper: WortiseWrapper)
    {
        dummyView = wortiseWrapper.CreateDummyController()
        
        if let topView = wortiseWrapper.GetTopViewController()
        {
            if (interstitialAd.isAvailable)
            {
                topView.addChild(dummyView)
                dummyView.view.frame = topView.view.bounds
                topView.view.addSubview(dummyView.view)
                dummyView.didMove(toParent: topView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                {
                    self.interstitialAd.showAd(from: self.dummyView)
                }
            }
        }
        else
        {
            NSLog("ERROR! Couldnt find top view for interstitial!!!!")
        }
    }
    
    func IsAvailable() -> Int32
    {
        if (interstitialAd != nil && interstitialAd.isAvailable)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
}

extension WortiseInterstitial : WAInterstitialDelegate
{
    func didClick(interstitialAd: WAInterstitialAd)
    {
        
    }
    
    func didDismiss(interstitialAd: WAInterstitialAd)
    {
        onDismissedCall?()
        
        if dummyView.parent != nil
        {
            dummyView.willMove(toParent: nil)
            dummyView.view.removeFromSuperview()
            dummyView.removeFromParent()
        }
    }
    
    func didFailToLoad(interstitialAd: WAInterstitialAd, error: WAAdError)
    {
        NSLog(error.message)
        onFailedToLoadCall?()
    }
    
    func didFailToShow(interstitialAd: WAInterstitialAd, error: WAAdError)
    {
        NSLog(error.message)
        onFailedToShowCall?()
    }
    
    func didImpress(interstitialAd: WAInterstitialAd)
    {
        
    }
    
    func didLoad(interstitialAd: WAInterstitialAd)
    {
        onLoadedCall?()
    }
    
    func didShow(interstitialAd: WAInterstitialAd)
    {
        
    }
}
