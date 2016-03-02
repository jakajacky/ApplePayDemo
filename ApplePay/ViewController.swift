//
//  ViewController.swift
//  ApplePay
//
//  Created by Xiaoqiang Zhang on 16/2/26.
//  Copyright © 2016年 Xiaoqiang Zhang. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {

  var summaryItems:[PKPaymentSummaryItem] = []
  var shippingMethods:[PKShippingMethod] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let btn = UIButton(type: UIButtonType.Custom)
    btn.frame = CGRectMake(60, 100, 200, 50)
    btn.center = self.view.center
    btn.setBackgroundImage(UIImage(named: "ApplePayBTN_64pt__whiteLine_textLogo_"), forState: UIControlState.Normal)
    
    btn.addTarget(self, action: "ApplePay", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(btn)
  
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func ApplePay() {
    
    // 检测是否支持ApplePay
    if PKPaymentAuthorizationViewController.canMakePayments() {
      print("support ApplePay")
      
      // 创建一个request
      let pkPayRequest = PKPaymentRequest()
      
      // 创建商品item
      let pkPayItem1    = PKPaymentSummaryItem(label: "Lamborghini LP650", amount: NSDecimalNumber(string: "1"))
      
      let pkPayItem2    = PKPaymentSummaryItem(label: "La Ferrari", amount: NSDecimalNumber(string: "1"))
      
      let pkPayItem3    = PKPaymentSummaryItem(label: "Shelby Super Car", amount: NSDecimalNumber(string: "1"))
      
      let pkPayItem4    = PKPaymentSummaryItem(label: "Das Auto", amount: NSDecimalNumber(string: "3"), type: PKPaymentSummaryItemType.Final)
      
      // 为request配置属性
      pkPayRequest.paymentSummaryItems = [pkPayItem1, pkPayItem2, pkPayItem3, pkPayItem4]
      self.summaryItems = [pkPayItem1, pkPayItem2, pkPayItem3, pkPayItem4]
      pkPayRequest.countryCode = "CN"
      pkPayRequest.currencyCode = "CNY"
      //支持的卡类型 iOS 9.2新增了PKPaymentNetworkChinaUnionPay
      pkPayRequest.supportedNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkDiscover]
      pkPayRequest.merchantIdentifier = "merchant.com.example.lbapplepaydemo"
      /*
      PKMerchantCapability.Credit NS_ENUM_AVAILABLE_IOS(9_0)   = 1UL << 2,   // 支持信用卡
      PKMerchantCapability.Debit  NS_ENUM_AVAILABLE_IOS(9_0)   = 1UL << 3    // 支持借记卡
      */
      pkPayRequest.merchantCapabilities = PKMerchantCapability.Capability3DS
      
      // 增加信息
      // 卡牌账单地址、
//      pkPayRequest.requiredBillingAddressFields = PKAddressField.Email
      // 邮寄地址
      pkPayRequest.requiredShippingAddressFields = PKAddressField.PostalAddress
      pkPayRequest.shippingType = PKShippingType.Delivery
      
      // 邮寄方式
      let method1 = PKShippingMethod(label: "顺丰快递", amount: NSDecimalNumber(string: "12"))
      method1.identifier = "sf"
      method1.detail = "全国包邮"
      let method2 = PKShippingMethod(label: "圆通快递", amount: NSDecimalNumber(string: "10"))
      method2.identifier = "yt"
      method2.detail = "全国包邮"
      
      pkPayRequest.shippingMethods = [method1, method2]
      self.shippingMethods         = [method1, method2];
      // 创建支付VC
      let pkVC = PKPaymentAuthorizationViewController(paymentRequest: pkPayRequest)
      pkVC.delegate = self
      self.presentViewController(pkVC, animated: true, completion: { () -> Void in
        
      })
    }
    else {
      print("该设备不支持支付")
    }
  }

}


// PKPayment Delegate
extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
  
  // 支付状态
  func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
    print(payment.token)
    
    let asyncSuccessful:Bool = false;
    /**
    将支付令牌payment上传服务器端，验证签名，获取token？
    */
//    let error:NSError
//    let addressMultiValue = ABRecordCopyValue(payment.billingContact, kABPersonAddressProperty) as! ABMultiValue
//    let addressDictionary = ABMultiValueCopyValueAtIndex(addressMultiValue, 0) as! AnyObject
//    do {
//      let json = try NSJSONSerialization.dataWithJSONObject(addressDictionary, options: NSJSONWritingOptions.PrettyPrinted)
//    }
//    catch {
//      
//    }
    // ... Send payment token, shipping and billing address, and order information to your server ...
    
    // 根据返回，判断成功与否
    if asyncSuccessful {
      completion(PKPaymentAuthorizationStatus.Success)
      print("支付成功")
    }
    else {
      completion(PKPaymentAuthorizationStatus.Failure)
      print("支付失败")
    }
  }
  
  // 支付完成
  func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
    
    controller .dismissViewControllerAnimated(true) { () -> Void in
    
    }
  }
  
  // 支付shippingMethod，可以处理“配送方式”
  func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didSelectShippingMethod shippingMethod: PKShippingMethod, completion: (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
    print(shippingMethod.detail)
    completion(PKPaymentAuthorizationStatus.Success, self.summaryItems)
  }
  
  // 可以处理“地址”
  func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didSelectShippingAddress address: ABRecord, completion: (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
    print(address)
    completion(PKPaymentAuthorizationStatus.Success, self.shippingMethods,self.summaryItems)
  }

}