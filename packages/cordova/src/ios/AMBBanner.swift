class AMBBanner: AMBAdBase, GADBannerViewDelegate {
    static var stackView = UIStackView()

    var bannerView: GADBannerView!
    var adSize: GADAdSize!
    var position: String!

    var stackView: UIStackView {
        return AMBBanner.stackView
    }

    var rootView: UIView {
        return self.plugin.viewController.view
    }

    var mainView: UIView {
        return self.plugin.webView
    }

    init(id: Int, adUnitId: String, adSize: GADAdSize, position: String) {
        super.init(id: id, adUnitId: adUnitId)

        self.adSize = adSize
        self.position = position

        if stackView.arrangedSubviews.isEmpty {
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            rootView.addSubview(stackView)
            stackView.addArrangedSubview(mainView)

            let backgroundView = UIView()
            backgroundView.backgroundColor = .black
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            stackView.insertSubview(backgroundView, at: 0)
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: stackView.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
            ])

            let guide = rootView.safeAreaLayoutGuide
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
                stackView.topAnchor.constraint(equalTo: guide.topAnchor)
            ])
        }
    }

    deinit {
        bannerView = nil
        adSize = nil
        position = nil
    }

    static func getAdSize(_ opts: NSDictionary) -> GADAdSize {
        if let adSizeType = opts.value(forKey: "size") as? Int {
            switch adSizeType {
            case 0:
                return kGADAdSizeBanner
            case 1:
                return kGADAdSizeLargeBanner
            case 2:
                return kGADAdSizeMediumRectangle
            case 3:
                return kGADAdSizeFullBanner
            case 4:
                return kGADAdSizeLeaderboard
            default: break
            }
        }
        guard let adSizeDict = opts.value(forKey: "size") as? NSDictionary,
              let width = adSizeDict.value(forKey: "width") as? Int,
              let height = adSizeDict.value(forKey: "height") as? Int
        else {
            return kGADAdSizeBanner
        }
        return GADAdSizeFromCGSize(CGSize(width: width, height: height))
    }

    func show(request: GADRequest) {
        if bannerView == nil {
            bannerView = GADBannerView(adSize: self.adSize)
            bannerView.delegate = self
            bannerView.rootViewController = plugin.viewController
        } else {
            bannerView.isHidden = false
        }

        switch position {
        case AMBBannerPosition.top:
            stackView.insertArrangedSubview(bannerView, at: 0)
        default:
            stackView.addArrangedSubview(bannerView)
        }

        bannerView.adUnitID = adUnitId
        bannerView.load(request)
    }

    func hide() {
        if bannerView != nil {
            bannerView.isHidden = true
            stackView.removeArrangedSubview(bannerView)
        }
    }

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.emit(AMBEvents.bannerLoad)
    }

    func bannerView(_ bannerView: GADBannerView,
                    didFailToReceiveAdWithError error: Error) {
        self.emit(AMBEvents.bannerLoadFail, error)
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        self.emit(AMBEvents.bannerImpression)
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        self.emit(AMBEvents.bannerOpen)
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        self.emit(AMBEvents.bannerClose)
    }
}
