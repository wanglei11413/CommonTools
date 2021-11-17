//
//  HomeViewController.swift
//  CommonTools
//
//  Created by Mac on 2021/9/27.
//

import UIKit

class HomeViewController: BaseViewController {
    
    private lazy var valueLabel: UILabel = {
        let label       = UILabel()
        label.textColor = TextColor_DarkGray
        label.font      = BoldFont(30)
        label.text      = "滑动值：40"
        return label
    }()
    private lazy var sliderView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var slider: WLCircleSlider = {
        let slider                      = WLCircleSlider.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth))
        slider.lineWidth                = 2
        slider.startAngle               = 147
        slider.endAngle                 = 33
        slider.trackFilledColor         = RGBColor(0, 142, 255)
        slider.trackColor               = .gray
        slider.thumbSize                = 12
        slider.thumbColor               = RGBColor(0, 142, 255)
        slider.shadowColor              = RGBColor(0, 142, 255)
        slider.minimumValue             = 0
        slider.maximumValue             = 100
        slider.currentValue             = 40
        slider.delegate                 = self
        return slider
    }() // 滑块

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
    }
    
    // MARK: - privates methods
    private func makeUI() {
        self.navigationItem.title = "圆弧Slider"
        
        self.view.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        self.view.addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kScreenWidth)
        }
        sliderView.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension HomeViewController: WLCircleSliderDelegate {
    func sliderValueChanged(sender: WLCircleSlider, value: Int) {
        valueLabel.text = "滑块值：" + "\(value)"
    }
    func sliderValueChangedEnd(sender: WLCircleSlider, value: Int) {
        
    }
}
