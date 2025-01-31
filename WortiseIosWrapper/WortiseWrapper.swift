import Foundation
import WortiseSDK
import UIKit

public typealias UnityCallback = @convention(c) () -> Void
public typealias UnityCallbackInt32 = @convention(c) (Int32) -> Void
public typealias UnityCallbackString = @convention(c) (UnsafePointer<CChar>?) -> Void

class WortiseWrapper
{
    func InitializeWortise(assetKey: UnsafePointer<CChar>, testMode: Int32, contentRating: UnsafePointer<CChar>, onInitialized: @escaping UnityCallback)
    {
        let keyString = String(cString: assetKey)
        let ratingString = String(cString: contentRating)
        let testBool = testMode != 0
        
        WAAdSettings.testEnabled = testBool
        WAAdSettings.childDirected = false
        
        switch (ratingString)
        {
        case "MA": WAAdSettings.maxAdContentRating = WAAdContentRating.ma
        case "T": WAAdSettings.maxAdContentRating = WAAdContentRating.t
        default: WAAdSettings.maxAdContentRating = WAAdContentRating.t
        }
        
        WortiseAds.shared.initialize(assetKey: keyString)
        {
            onInitialized()
        }
    }
    
    func RequestConsentIfRequired()
    {
        let dummyView = CreateDummyController()
        
        if let topView = GetTopViewController()
        {
            topView.present(dummyView, animated: false, completion: nil)
            
            WAConsentManager.shared.request(ifRequired: dummyView)
            {
                _ in
                dummyView.dismiss(animated: false, completion: nil)
            }
        }
        else
        {
            NSLog("ERROR! Couldnt find top view for consent!!!!")
        }
    }
    
    func GetTopViewController() -> UIViewController?
    {
        if #available(iOS 13.0, *)
        {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else
            {
                return nil
            }
            
            return GetTopViewController(from: keyWindow.rootViewController)
        } else
        {
            guard let keyWindow = UIApplication.shared.keyWindow else
            {
                return nil
            }
            
            return GetTopViewController(from: keyWindow.rootViewController)
        }
    }
    
    func GetTopViewController(from vc: UIViewController?) -> UIViewController?
    {
        if let presentedVC = vc?.presentedViewController
        {
            return GetTopViewController(from: presentedVC)
        }
        else if let navigationVC = vc as? UINavigationController, let visibleVC = navigationVC.visibleViewController
        {
            return GetTopViewController(from: visibleVC)
        }
        else if let tabBarVC = vc as? UITabBarController, let selectedVC = tabBarVC.selectedViewController
        {
            return GetTopViewController(from: selectedVC)
        }
        
        return vc
    }
    
    func CreateDummyController() -> UIViewController
    {
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.view.backgroundColor = UIColor.clear
        return viewController
    }
}

let w = WortiseWrapper()

@_cdecl("InitializeWortise")
public func InitializeWortise(assetKey: UnsafePointer<CChar>, testMode: Int32, contentRating: UnsafePointer<CChar>, onInitialized: @escaping UnityCallback)
{
    w.InitializeWortise(assetKey: assetKey, testMode: testMode, contentRating: contentRating, onInitialized: onInitialized)
}

@_cdecl("RequestConsentIfRequired")
public func RequestConsentIfRequired()
{
    w.RequestConsentIfRequired()
}

let appOpen = WortiseAppOpen()

@_cdecl("LoadAppOpen")
public func LoadAppOpen(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onDismissed: @escaping UnityCallback)
{
    appOpen.LoadAppOpenAd(adID: adID, onLoaded: onLoaded, onFailedToLoad: onFailedToLoad, onDismissed: onDismissed)
}

@_cdecl("ShowAppOpen")
public func ShowAppOpen()
{
    appOpen.ShowAppOpen(wortiseWrapper: w)
}

@_cdecl("IsAppOpenAvailable")
public func IsAppOpenAvailable() -> Int32
{
    return appOpen.IsAvailable()
}

let banner = WortiseBanner()

@_cdecl("InitializeBanner")
public func InitializeBanner(adID: UnsafePointer<CChar>, bannerPosition: UnsafePointer<CChar>, refreshSecs: Double, onImpression: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback)
{
    banner.Initialize(wortiseWrap: w, adID: adID, bannerPosition: bannerPosition, refreshSecs: refreshSecs, onImpression: onImpression, onFailedToLoad: onFailedToLoad)
}

@_cdecl("LoadAndShowBanner")
public func LoadAndShowBanner(paddingPx: Int32)
{
    banner.LoadAndShowAd(paddingPxFromBorder: paddingPx)
}

@_cdecl("IsBannerLoading")
public func IsBannerLoading() -> Int32
{
    return banner.IsBannerLoading()
}

@_cdecl("DestroyBanner")
public func DestroyBanner()
{
    banner.DestroyBannerAd()
}

@_cdecl("GetBannerAdPixelHeight")
public func GetBannerAdPixelHeight() -> Int32
{
    return banner.AdPixelHeight()
}

let interstitial = WortiseInterstitial()

@_cdecl("LoadInterstitialAd")
public func LoadInterstitialAd(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onFailedToShow: @escaping UnityCallback, onDismissed: @escaping UnityCallback)
{
    interstitial.LoadInterstitialAd(adID: adID, onLoaded: onLoaded, onFailedToLoad: onFailedToLoad, onFailedToShow: onFailedToShow, onDismissed: onDismissed)
}

@_cdecl("ShowInterstitial")
public func ShowInterstitial()
{
    interstitial.ShowInterstitial(wortiseWrapper: w)
}

@_cdecl("IsInterstitialAvailable")
public func IsInterstitialAvailable() -> Int32
{
    return interstitial.IsAvailable()
}

let rewarded = WortiseRewarded()

@_cdecl("LoadRewardedAd")
public func LoadRewardedAd(adID: UnsafePointer<CChar>, onLoaded: @escaping UnityCallback, onFailedToLoad: @escaping UnityCallback, onFailedToShow: @escaping UnityCallback, onDismissed: @escaping UnityCallback, onCompletedAd: @escaping UnityCallback)
{
    rewarded.LoadRewardedAd(adID: adID, onLoaded: onLoaded, onFailedToLoad: onFailedToLoad, onFailedToShow: onFailedToShow, onDismissed: onDismissed, onCompletedAd: onCompletedAd)
}

@_cdecl("ShowRewarded")
public func ShowRewarded()
{
    rewarded.ShowRewarded(wortiseWrapper: w)
}

@_cdecl("IsRewardedAvailable")
public func IsRewardedAvailable() -> Int32
{
    return rewarded.IsAvailable()
}
