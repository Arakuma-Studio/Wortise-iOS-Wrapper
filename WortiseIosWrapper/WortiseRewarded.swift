import Foundation
import WortiseSDK
import UIKit

class WortiseRewarded
{
    var rewarded: WARewardedAd!
    var onLoadedCall: UnityCallback?
    var onFailedToLoadCall: UnityCallback?
    var onFailedToShowCall: UnityCallback?
    var onDismissedCall: UnityCallback?
    var onCompletedAdCall: UnityCallback?
    var dummyView: UIViewController!
    
    func LoadRewardedAd(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onFailedToShow: @escaping UnityCallback, onDismissed: @escaping UnityCallback, onCompletedAd: @escaping UnityCallback)
    {
        if (rewarded != nil)
        {
            rewarded.destroy()
            rewarded = nil
        }
        
        let adIdString = String(cString: adID)
        rewarded = WARewardedAd(adUnitId: adIdString)
        onLoadedCall = onLoaded
        onFailedToLoadCall = onFailedToLoad
        onFailedToShowCall = onFailedToShow
        onDismissedCall = onDismissed
        onCompletedAdCall = onCompletedAd
        rewarded.delegate = self
        rewarded.loadAd()
    }
    
    func ShowRewarded(wortiseWrapper: WortiseWrapper)
    {
        dummyView = wortiseWrapper.CreateDummyController()
        
        if let topView = wortiseWrapper.GetTopViewController()
        {
            if (rewarded.isAvailable)
            {
                topView.addChild(dummyView)
                dummyView.view.frame = topView.view.bounds
                topView.view.addSubview(dummyView.view)
                dummyView.didMove(toParent: topView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                {
                    self.rewarded.showAd(from: self.dummyView)
                }
            }
        }
        else
        {
            NSLog("ERROR! Couldnt find top view for rewarded!!!!")
        }
    }
    
    func IsAvailable() -> Int32
    {
        if (rewarded != nil && rewarded.isAvailable)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
}

extension WortiseRewarded : WARewardedDelegate
{
    func didClick(rewardedAd: WARewardedAd)
    {
        
    }
    
    func didDismiss(rewardedAd: WARewardedAd)
    {
        onDismissedCall?()
        
        if dummyView.parent != nil
        {
            dummyView.willMove(toParent: nil)
            dummyView.view.removeFromSuperview()
            dummyView.removeFromParent()
        }
    }
    
    func didFailToLoad(rewardedAd: WARewardedAd, error: WAAdError)
    {
        NSLog(error.message)
        onFailedToLoadCall?()
    }
    
    func didFailToShow(rewardedAd: WARewardedAd, error: WAAdError)
    {
        NSLog(error.message)
        onFailedToShowCall?()
    }
    
    func didImpress(rewardedAd: WARewardedAd)
    {
        
    }
    
    func didLoad(rewardedAd: WARewardedAd)
    {
        onLoadedCall?()
    }
    
    func didShow(rewardedAd: WARewardedAd)
    {
        
    }
    
    func didComplete(rewardedAd: WARewardedAd, reward: WAReward)
    {
        onCompletedAdCall?()
    }
}
