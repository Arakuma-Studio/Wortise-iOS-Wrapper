import Foundation
import WortiseSDK
import UIKit

class WortiseAppOpen
{
    var appOpenAd: WAAppOpenAd!
    var onLoadedCall: UnityCallback?
    var onFailedToLoadCall: UnityCallback?
    var onDismissedCall: UnityCallback?
    var dummyView: UIViewController!
    
    func LoadAppOpenAd(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onDismissed: @escaping UnityCallback)
    {
        if (appOpenAd != nil)
        {
            appOpenAd.destroy()
            appOpenAd = nil
        }
        
        let adIdString = String(cString: adID)
        appOpenAd = WAAppOpenAd(adUnitId: adIdString)
        onLoadedCall = onLoaded
        onFailedToLoadCall = onFailedToLoad
        onDismissedCall = onDismissed
        appOpenAd.delegate = self
        appOpenAd.loadAd()
    }
    
    func ShowAppOpen(wortiseWrapper: WortiseWrapper)
    {
        dummyView = wortiseWrapper.CreateDummyController()
        
        if let topView = wortiseWrapper.GetTopViewController()
        {
            if (appOpenAd.isAvailable)
            {
                topView.addChild(dummyView)
                dummyView.view.frame = topView.view.bounds
                topView.view.addSubview(dummyView.view)
                dummyView.didMove(toParent: topView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                {
                    self.appOpenAd.tryToShowAd(from: self.dummyView)
                }
            }
        }
        else
        {
            NSLog("ERROR! Couldnt find top view for app open!!!!")
        }
    }
    
    func IsAvailable() -> Int32
    {
        if (appOpenAd != nil && appOpenAd.isAvailable)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
}

extension WortiseAppOpen : WAAppOpenDelegate
{
    func didClick(appOpenAd: WAAppOpenAd)
    {
        
    }
    
    func didDismiss(appOpenAd: WAAppOpenAd)
    {
        onDismissedCall?()
        
        if dummyView.parent != nil
        {
            dummyView.willMove(toParent: nil)
            dummyView.view.removeFromSuperview()
            dummyView.removeFromParent()
        }
    }
    
    func didFailToLoad(appOpenAd: WAAppOpenAd, error: WAAdError)
    {
        NSLog(error.message)
        onFailedToLoadCall?()
    }
    
    func didFailToShow(appOpenAd: WAAppOpenAd, error: WAAdError)
    {
        NSLog(error.message)
    }
    
    func didImpress(appOpenAd: WAAppOpenAd)
    {
            
    }
    
    func didLoad(appOpenAd: WAAppOpenAd)
    {
        onLoadedCall?()
    }
    
    func didShow(appOpenAd: WAAppOpenAd)
    {
        
    }
}
