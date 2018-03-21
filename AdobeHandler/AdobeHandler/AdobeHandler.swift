//
//  AdobeHandler.swift
//  AdobeHandler
//
//  Created by Julien Gil on 12/03/2018.
//  Copyright © 2018 com.fifty-five. All rights reserved.
//

import Foundation
import CargoCore
import CoreLocation

/// The class which handles interactions with the Accengage SDK.
public class AdobeHandler: CARTagHandler {
    /** Constants used to define callbacks in the register and in the execute method */
    let ADB_INIT = "ADB_init";
    let ADB_SET_PRIVACY = "ADB_setPrivacy";
    let ADB_TAG_EVENT = "ADB_tagEvent";
    let ADB_TAG_SCREEN = "ADB_tagScreen";
    let ADB_TRACK_LOCATION = "ADB_trackLocation";
    let ADB_SEND_QUEUE_HITS = "ADB_sendQueueHits";
    let ADB_CLEAR_QUEUE = "ADB_clearQueue";
    let ADB_TRACK_PUSH_MESSAGE = "ADB_trackPushMessage";
    let ADB_COLLECT_LIFE_CYCLE = "ADB_collectLyfeCycle";
    let ADB_TRACK_TIME_START = "ADB_trackTimeStart";
    let ADB_TRACK_TIME_END = "ADB_trackTimeEnd";
    let ADB_TRACK_TIME_UPDATE = "ADB_trackTimeUpdate";
    let ADB_INCREASE_LIFETIME_VALUE = "ADB_increaseLifeTimeValue";

    /** Constants used whithin the file */
    let ACTION_NAME = "actionName";
    
    
/* ********************************** Handler core methods ************************************** */
    
    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    @objc public init() {
        super.init(key: "ADB", name: "Adobe");
    }
    
    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override public func execute(_ tagName: String, parameters: [AnyHashable: Any]){
        super.execute(tagName, parameters: parameters);
        
        if (tagName == ADB_INIT) {
            self.initialize(parameters: parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
            case ADB_SET_PRIVACY:
                self.setPrivacy(parameters: parameters);
                break;
            case ADB_TAG_EVENT:
                self.tagEvent(parameters: parameters);
                break;
            case ADB_TAG_SCREEN:
                self.tagScreen(parameters: parameters);
                break;
            case ADB_TRACK_LOCATION:
                self.trackLocation(parameters: parameters);
                break;
            case ADB_TRACK_PUSH_MESSAGE:
                self.trackPushMessage(parameters: parameters);
                break;
            case ADB_COLLECT_LIFE_CYCLE:
                self.collectLifeCycle(parameters: parameters);
                break;
            case ADB_TRACK_TIME_START:
                self.trackTimeStart(parameters: parameters);
                break;
            case ADB_TRACK_TIME_END:
                self.trackTimeEnd(parameters: parameters);
                break;
            case ADB_TRACK_TIME_UPDATE:
                self.trackTimeUpdate(parameters: parameters);
                break;
            case ADB_INCREASE_LIFETIME_VALUE:
                self.increaseVisitorLifetimeValue(parameters: parameters);
            case ADB_SEND_QUEUE_HITS:
                self.sendQueueHits();
                break;
            case ADB_CLEAR_QUEUE:
                self.clearQueue();
                break;
            default:
                logger.logUnknownFunctionTag(tagName);
            }
        }
        else {
            logger.logUninitializedFramework();
        }
    }
    
    
/* ************************************ SDK initialization ************************************** */

    /// The method you need to call first. Allow you to initialize Adobe SDK
    /// It automatically sets the log level after the CargoCore one, but you may also specify
    /// a new path for the JSON config file, or set additional data to the life cycle collection.
    ///
    /// - Parameters:
    ///   - overrideConfigPath: the name, without its extension, of the JSON config file to use.
    ///   - parameters: all the other parameters are given as parameters for the collectLifeCycle method
    fileprivate func initialize(parameters: [AnyHashable: Any]){
        let overrideConfigPath = "overrideConfigPath";
        var params = parameters;

        // set the handler as initialized.
        self.initialized = true;
        // get the filename, and set it as the config file which should be used by the SDK
        if let overrideConfig = params[overrideConfigPath] {
            if let configPath = Bundle.main.path(forResource: overrideConfig as? String,
                                                         ofType: "json") {
                ADBMobile.overrideConfigPath(configPath);
                self.logger.logParamSetWithSuccess(overrideConfigPath, value: configPath);
            }
            else {
                self.logger.carLog(CARLogger.LogLevelType.error, message: "\(overrideConfig).json not found.")
                // set the handler as uninitialized.
                self.initialized = false;
                return;
            }
            params.removeValue(forKey: overrideConfigPath);
        }

        // checks wether the initial log level is verbose/debug, and activate the SDK's logs if so.
        if (self.logger.level.rawValue <= CARLogger.LogLevelType.debug.rawValue) {
            ADBMobile.setDebugLogging(true);
        } else {
            ADBMobile.setDebugLogging(false);
        }

        // calls the collectLifeCycle method with all the parameters left in the given parameters.
        self.collectLifeCycle(parameters: params);
    }
    

/* ****************************************** Tracking ****************************************** */

    /// Method used to update the privacy status of the user, with the 'privacyStatus' key
    /// - Parameters:
    ///   - privacyStatus: takes one of the following values :
    ///     - OPT_IN, where the hits are sent immediately.
    ///     - OPT_OUT, where the hits are discarded.
    ///     - UNKNOWN, where if your report suite is timestamp enabled,
    ///       hits are saved until the privacy status changes to opt-in (hits are sent)
    ///       or opt-out (hits are discarded). If your report suite is not timestamp enabled,
    ///       hits are discarded until the privacy status changes to opt in.
    fileprivate func setPrivacy(parameters: [AnyHashable: Any]) {
        let status = "privacyStatus";
        let OPT_IN = "OPT_IN";
        let OPT_OUT = "OPT_OUT";
        let UNKNOWN = "UNKNOWN";
        
        if let privacyStatus = parameters[status] {
            if (privacyStatus as! String == OPT_IN) {
                ADBMobile.setPrivacyStatus(ADBMobilePrivacyStatus.optIn);
                self.logger.logParamSetWithSuccess(status, value: privacyStatus);
            }
            else if (privacyStatus as! String == OPT_OUT) {
                ADBMobile.setPrivacyStatus(ADBMobilePrivacyStatus.optOut);
                self.logger.logParamSetWithSuccess(status, value: privacyStatus);
            }
            else if (privacyStatus as! String == UNKNOWN) {
                ADBMobile.setPrivacyStatus(ADBMobilePrivacyStatus.unknown);
                self.logger.logParamSetWithSuccess(status, value: privacyStatus);
            }
            else {
                self.logger.logNotFoundValue(privacyStatus as! String, key: status,
                                             possibleValues: [OPT_IN, OPT_OUT, UNKNOWN]);
            }
        }
        else {
            self.logger.logMissingParam(status, methodName: ADB_SET_PRIVACY);
        }
    }

    /// Indicates to the SDK that lifecycle data should be collected for use across all solutions
    /// in the SDK. Giving extra parameters to this method allows you to pass in additional data
    /// when collecting lifecycle metrics. This method must be called from the entry point
    /// of your app.
    /// NB : this method is already automatically called when calling on ADB_init.
    /// see more at : https://marketing.adobe.com/resources/help/en_US/mobile/ios/sdk_methods.html
    /// - Parameters:
    ///   - parameters: all the parameters are passed to the SDK function as additional data.
    fileprivate func collectLifeCycle(parameters: [AnyHashable: Any]) {
        // if there is any parameter, these are given to the appropriate SDK function
        if (parameters.count > 0) {
            ADBMobile.collectLifecycleData(withAdditionalData: parameters);
            self.logger.logParamSetWithSuccess("collectLifeCycle parameters", value: parameters);
        }
        // otherwise, the SDK function without any parameter is called
        else {
            ADBMobile.collectLifecycleData();
        }
        self.logger.carLog(CARLogger.LogLevelType.verbose, message: "Lifecycle data is now collected");
    }

    /// Send an event/action to the Adobe SDK.
    ///
    /// - Parameters:
    ///   - eventName: the name of the action, which is mandatory
    ///   - parameters: all the parameters left are passed as additional data.
    fileprivate func tagEvent(parameters: [AnyHashable: Any]) {
        var params = parameters;

        // sets the action name, the eventual additional data, sends the hit and logs,
        // depending on the parameters that have been given.
        if let eventName = parameters[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME);
            ADBMobile.trackAction(eventName as? String, data: params);
            self.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
            if (params.count > 0) {
                self.logger.logParamSetWithSuccess("eventParameters", value: params);
            }
        }
        else {
            self.logger.logMissingParam(EVENT_NAME, methodName: ADB_TAG_EVENT);
        }
    }

    /// Send a screen/state to the Adobe SDK.
    ///
    /// - Parameters:
    ///   - screenName: the name of the state, which is mandatory
    ///   - parameters: all the parameters left are passed as additional data.
    fileprivate func tagScreen(parameters: [AnyHashable: Any]) {
        var params = parameters;

        // sets the action name, the eventual additional data, sends the hit and logs,
        // depending on the parameters that have been given.
        if let screenName = parameters[SCREEN_NAME] {
            params.removeValue(forKey: SCREEN_NAME);
            ADBMobile.trackState(screenName as? String, data: params);
            self.logger.logParamSetWithSuccess(SCREEN_NAME, value: screenName);
            if (params.count > 0) {
                self.logger.logParamSetWithSuccess("screenParameters", value: params);
            }
        }
        else {
            self.logger.logMissingParam(SCREEN_NAME, methodName: ADB_TAG_SCREEN);
        }
    }

    /// Send a location to the Adobe SDK. If the CLLocation object is nil, nothing happens.
    /// The location has to be set through the CargoLocation class before calling on this method.
    /// The CargoLocation class is available in the CargoCore.framework.
    /// This method will retrieve the location previously set to pass it to the Adobe SDK.
    /// You may pass parameters, which will be treated as additional data.
    ///
    /// - Parameters:
    ///   - parameters: all the parameters given here are passed as additional data.
    fileprivate func trackLocation(parameters: [AnyHashable: Any]) {
        // if there is a location to retrieve, it is set, along with the additional data
        if let location = CargoLocation.getLocation() {
            ADBMobile.trackLocation(location, data: parameters);
            self.logger.logParamSetWithSuccess("location", value: location);
            if (parameters.count > 0) {
                self.logger.logParamSetWithSuccess("locationParameters", value: parameters);
            }
        }
        else {
            self.logger.logMissingParam("location", methodName: ADB_TRACK_LOCATION);
        }
    }

    /// Tracks a push message click-through.
    /// See more at : https://marketing.adobe.com/resources/help/en_US/mobile/ios/analytics_methods.html
    /// - Parameters:
    ///   - parameters: all the parameters are given to the method.
    fileprivate func trackPushMessage(parameters: [AnyHashable: Any]) {
        // send the hit only when there is parameters.
        if (parameters.count > 0) {
            ADBMobile.trackPushMessageClickThrough(parameters);
            self.logger.logParamSetWithSuccess("Push Message", value: parameters);
        }
        else {
            self.logger.logMissingParam("Push Message parameters", methodName: ADB_TRACK_PUSH_MESSAGE);
        }
    }

    /// The timed actions measure the in-app time and total time between the start and the end of
    /// an action. You can use timed actions to define segments and compare time to purchase,
    /// pass level, checkout flow, and so on.
    /// Start the counter for the mentioned actionName.
    /// If you call this method for an action that has already started, the previous timed action
    /// is overwritten. Calling this method doesn't send a hit.
    /// - Parameters:
    ///   - actionName: the name of the action you want to track the time it takes.
    ///   - parameters: all the parameters left are passed as additional data.
    fileprivate func trackTimeStart(parameters: [AnyHashable: Any]) {
        var params = parameters;

        if let actionName = params[ACTION_NAME] {
            params.removeValue(forKey: ACTION_NAME);
            ADBMobile.trackTimedActionStart(actionName as? String, data: params);
            self.logger.logParamSetWithSuccess(ACTION_NAME, value: actionName);
            if (params.count > 0) {
                self.logger.logParamSetWithSuccess("trackTimeStart parameters", value: params);
            }
        }
        else {
            self.logger.logMissingParam(ACTION_NAME, methodName: ADB_TRACK_TIME_START);
        }
    }

    /// Can be called at any point with the timed action name to add additional context data.
    /// The data that is passed in is appended to the existing data for the action,
    /// and if the same key is already defined for action, overwrites the data. Calling this method
    /// doesn't send a hit.
    /// - Parameters:
    ///   - actionName: the name of the action you want to update data.
    ///   - parameters: all the parameters left are passed as additional data updates.
    fileprivate func trackTimeUpdate(parameters: [AnyHashable: Any]) {
        var params = parameters;
        
        if let actionName = params[ACTION_NAME] {
            params.removeValue(forKey: ACTION_NAME);
            if (params.count > 0) {
                ADBMobile.trackTimedActionUpdate(actionName as? String, data: params);
                self.logger.logParamSetWithSuccess(ACTION_NAME, value: actionName);
                self.logger.logParamSetWithSuccess("trackTimeUpdate parameters", value: params);
            }
            else {
                self.logger.logMissingParam("trackTimeUpdate parameters",
                                            methodName: ADB_TRACK_TIME_UPDATE);
            }
        }
        else {
            self.logger.logMissingParam(ACTION_NAME, methodName: ADB_TRACK_TIME_UPDATE);
        }
    }

    /// The timed actions measure the in-app time and total time between the start and the end of
    /// an action. You can use timed actions to define segments and compare time to purchase,
    /// pass level, checkout flow, and so on.
    /// Stop the counter for the mentioned actionName, and send a hit, if you want to.
    /// - Parameters:
    ///   - actionName: the name of the action you want to end the time measure for.
    ///   - successfulAction: a boolean. If set to false, it won't send the hit, otherwise it will.
    ///   - parameters: all the parameters left are passed as additional data updates.
    fileprivate func trackTimeEnd(parameters: [AnyHashable: Any]) {
        let successfulAction = "successfulAction";
        var sendHit = true;
        var params = parameters;

        // retrieve the actionName and delete it from the parameters
        if let actionName = params[ACTION_NAME] {
            params.removeValue(forKey: ACTION_NAME);
            // retrieve the successfulAction boolean and delete it from the parameters.
            // if it doesn't exist in the parameters, the hit will be sent anyway (default = true).
            if let actionSuccess = params[successfulAction] {
                params.removeValue(forKey: successfulAction);
                sendHit = actionSuccess as! Bool;
            }
            // update the additional data before sending (or not) the hit
            ADBMobile.trackTimedActionEnd(actionName as? String, logic: {( inApp, total, data) in
                data?.addEntries(from: params);
                return sendHit;
            });

            // logs depending on the circumstances
            if (sendHit == false) {
                self.logger.carLog(CARLogger.LogLevelType.verbose,
                                   message: "The \(ACTION_NAME) Timed Action wasn't sent because the \(successfulAction) boolean has been set to false");
            }
            else {
                self.logger.carLog(CARLogger.LogLevelType.verbose,
                                   message: "The \(ACTION_NAME) Timed Action has been sent with the following additional data : \(params)");
            }
        }
        else {
            self.logger.logMissingParam(ACTION_NAME, methodName: ADB_TRACK_TIME_END);
        }
    }

    /// The lifetime value allows you to measure and target on a lifetime value for each user.
    /// The value can be used to store lifetime purchases, ad views, video completes, and so on.
    /// Each time you send in a value with this method, it is added to the existing value.
    /// - Parameters:
    ///   - increaseVisitorLifetimeValue: A decimal number to add to the existing amount for this user.
    ///   - parameters: all the parameters left are passed as additional data.
    fileprivate func increaseVisitorLifetimeValue(parameters: [AnyHashable: Any]) {
        let LTValue = "increaseVisitorLifetimeValue";
        var params = parameters;

        // retrieve the increaseVisitorLifetimeValue parameter value, removes it from the parameters,
        // set it and set the parameters left as additional data.
        if let amount = params[LTValue] {
            params.removeValue(forKey: LTValue);
            ADBMobile.trackLifetimeValueIncrease(amount as? NSDecimalNumber, data:params);
            self.logger.logParamSetWithSuccess(LTValue, value: amount);
            if (params.count > 0) {
                self.logger.logParamSetWithSuccess("LifetimeValue parameters", value: params);
            }
        }
        else {
            self.logger.logMissingParam(LTValue, methodName: ADB_INCREASE_LIFETIME_VALUE);
        }
    }

    /// Regardless of how many hits are queued,
    /// this method forces the Adobe SDK to send all hits in the offline queue.
    fileprivate func sendQueueHits() {
        let queueSize = ADBMobile.trackingGetQueueSize();
        
        ADBMobile.trackingSendQueuedHits();
        self.logger.carLog(CARLogger.LogLevelType.verbose,
                           message: "Forced to send \(queueSize) hits from queue");
    }

    /// Clears all the hits from the offline queue.
    /// Use it with caution. This process cannot be reversed.
    fileprivate func clearQueue() {
        let queueSize = ADBMobile.trackingGetQueueSize();
        
        ADBMobile.trackingClearQueue();
        self.logger.carLog(CARLogger.LogLevelType.verbose,
                           message: "Cleared \(queueSize) hits from queue");
    }

}








