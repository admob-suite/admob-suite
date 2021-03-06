class AMBInterstitial: AMBAdBase, GADFullScreenContentDelegate {
    var interstitial: GADInterstitialAd?

    deinit {
        interstitial = nil
    }

    func isLoaded() -> Bool {
        return self.interstitial != nil
    }

    func load(_ ctx: AMBContext, request: GADRequest) {
        GADInterstitialAd.load(
            withAdUnitID: adUnitId,
            request: request,
            completionHandler: { ad, error in
                if error != nil {
                    self.emit(AMBEvents.interstitialLoadFail, error!)
                    ctx.error(error)
                    return
                }

                self.interstitial = ad
                ad?.fullScreenContentDelegate = self

                self.emit(AMBEvents.interstitialLoad)

                ctx.success()
         })
    }

    func show(_ ctx: AMBContext) {
        if isLoaded() {
            interstitial?.present(fromRootViewController: plugin.viewController)
        }

        ctx.success()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.emit(AMBEvents.interstitialShowFail, error)
    }

    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.emit(AMBEvents.interstitialShow)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.emit(AMBEvents.interstitialDismiss)
    }
}
