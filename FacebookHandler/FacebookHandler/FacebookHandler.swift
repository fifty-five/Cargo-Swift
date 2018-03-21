//
//  FacebookHandler.swift
//  Cargo
//
//  Created by François K on 06/09/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

import Foundation
import CargoCore
import FBSDKCoreKit

/// The class which handles interactions with the Accengage SDK.
public class FacebookHandler: CARTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** Constants used to define callbacks in the register and in the execute method */
    let FB_INIT = "FB_init";
    let FB_ACTIVATE_APP = "FB_activateApp";
    let FB_TAG_EVENT = "FB_tagEvent";
    let FB_TAG_PURCHASE = "FB_tagPurchase";

    var debug: Bool = false;


/* ********************************** Handler core methods ************************************** */

    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    @objc public init() {
        super.init(key: "FB", name: "Facebook");
        // enables Facebook debug mode if the cargo logger is set to debug, disables it otherwise
        if (self.logger.level.rawValue <= CARLogger.LogLevelType.debug.rawValue) {
            self.debug = true;
        } else {
            self.debug = false;
        }
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override public func execute(_ tagName: String, parameters: [AnyHashable: Any]){
        super.execute(tagName, parameters: parameters);

        if (tagName == FB_INIT) {
            self.initialize(parameters: parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case FB_ACTIVATE_APP:
                    self.activateApp();
                    break ;
                case FB_TAG_EVENT:
                    self.tagEvent(parameters: parameters);
                    break ;
                case FB_TAG_PURCHASE:
                    self.purchase(parameters: parameters);
                    break ;
                default:
                    logger.logUnknownFunctionTag(tagName);
            }
        }
        else {
            logger.logUninitializedFramework();
        }
    }


/* ************************************ SDK initialization ************************************** */

    /// The method you need to call first. Allow you to initialize Facebook SDK
    /// Register the application ID to the Facebook SDK.
    ///
    /// - Parameters:
    ///   - applicationId: the ID facebook gives when you register your app
    fileprivate func initialize(parameters: [AnyHashable: Any]){
        if let applicationId = parameters[APPLICATION_ID]{
            FBSDKAppEvents.setLoggingOverrideAppID(applicationId as? String);
            self.activateApp();
            self.initialized = true;
            logger.logParamSetWithSuccess(APPLICATION_ID, value: applicationId);

            if (debug) {
                FBSDKSettings.enableLoggingBehavior(FBSDKLoggingBehaviorInformational);
            }
        }
        else {
            logger.logMissingParam(APPLICATION_ID, methodName: FB_INIT);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Needs to be called on each screen in order to measure sessions
    fileprivate func activateApp(){
        FBSDKAppEvents.activateApp();
        self.logger.carLog(.info, message: "Application activation hit sent.");
    }

    /// Send an event to facebook SDK. Calls differents methods depending on which parameters have been given
    /// Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
    /// When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
    /// that can represent any value (e.g., a price or a quantity).
    ///
    /// - Parameters:
    ///   - eventName: the name of the event, which is mandatory
    ///   - valueToSum: the value to sum
    ///   - parameters: other parameters you would like to link to the event
    fileprivate func tagEvent(parameters: [AnyHashable: Any]){
        var params = parameters;
        let VALUE_TO_SUM = "valueToSum";

        if let eventName = params[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME);

            if let valueToSum = params[VALUE_TO_SUM]{
                params.removeValue(forKey: VALUE_TO_SUM);

                // in case there is an eventName, valueToSum and additional parameters
                if(params.count > 0){
                    FBSDKAppEvents.logEvent(eventName as! String,
                                        valueToSum: (valueToSum as? Double)!,
                                        parameters: params);
                    logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
                    logger.logParamSetWithSuccess(VALUE_TO_SUM, value: valueToSum);
                    logger.logParamSetWithSuccess("params", value: params);
                }
                // in case there is an eventName and a valueToSum
                else{
                    FBSDKAppEvents.logEvent(eventName as! String, valueToSum: (valueToSum as? Double)!);
                    logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
                    logger.logParamSetWithSuccess(VALUE_TO_SUM, value: valueToSum);
                }
            }
            else{
                // in case there is an eventName and additional parameters
                if(params.count > 0){
                    FBSDKAppEvents.logEvent(eventName as! String,
                                        parameters: params);
                    logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
                    logger.logParamSetWithSuccess("params", value: params);
                }
                // in case there is just an eventName
                else{
                    FBSDKAppEvents.logEvent(eventName as! String);
                    logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
                }
            }
        }
        else {
            logger.logMissingParam(EVENT_NAME, methodName: FB_TAG_EVENT);
        }
    }

    /// Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
    /// The currency specification is expected to be an ISO 4217 currency code.
    ///
    /// - Parameters:
    ///   - transactionTotal: the amount of the purchase, which is mandatory
    ///   - transactionCurrencyCode: the currency of the purchase, which is mandatory
    fileprivate func purchase(parameters: [AnyHashable: Any]){
        if let purchaseAmount = parameters[TRANSACTION_TOTAL] as? Double {
            if let currencyCode = parameters[TRANSACTION_CURRENCY_CODE] as? String {
                FBSDKAppEvents.logPurchase(purchaseAmount, currency: currencyCode);
                logger.logParamSetWithSuccess(TRANSACTION_TOTAL, value: purchaseAmount);
                logger.logParamSetWithSuccess(TRANSACTION_CURRENCY_CODE, value: currencyCode);
            }
            else {
                logger.logMissingParam(TRANSACTION_CURRENCY_CODE, methodName: FB_TAG_PURCHASE);
            }
        }
        else {
            logger.logMissingParam(TRANSACTION_TOTAL, methodName: FB_TAG_PURCHASE);
        }
    }
}
