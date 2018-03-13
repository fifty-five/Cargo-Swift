//
//  AdobeHandler.swift
//  AdobeHandler
//
//  Created by Julien Gil on 12/03/2018.
//  Copyright © 2018 com.fifty-five. All rights reserved.
//

import Foundation
import CargoCore

/// The class which handles interactions with the Accengage SDK.
public class AdobeHandler: CARTagHandler {
    /** Constants used to define callbacks in the register and in the execute method */
    let ADB_INIT = "ADB_init";
    let ADB_TAG_EVENT = "ADB_tagEvent";
    let ADB_TAG_SCREEN = "ADB_tagScreen";
    
    
/* ********************************** Handler core methods ************************************** */
    
    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    public init() {
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
            case ADB_TAG_EVENT:
                self.tagEvent(parameters: parameters);
                break;
            case ADB_TAG_SCREEN:
                self.tagScreen(parameters: parameters);
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
    
    fileprivate func initialize(parameters: [AnyHashable: Any]){
        if let overrideConfig = parameters["overrideConfigPath"] {
            let configPath:String = Bundle.main.path(forResource: overrideConfig as? String, ofType: "json")!;
            ADBMobile.overrideConfigPath(configPath);
            self.logger.logParamSetWithSuccess("overrideConfigPath", value: configPath)
        }
        
        if (self.logger.level.rawValue <= CARLogger.LogLevelType.debug.rawValue) {
            ADBMobile.setDebugLogging(true);
        } else {
            ADBMobile.setDebugLogging(false);
        }
    }
    

/* ****************************************** Tracking ****************************************** */
    
    fileprivate func tagEvent(parameters: [AnyHashable: Any]) {
        var params = parameters;
        
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

    fileprivate func tagScreen(parameters: [AnyHashable: Any]) {
        var params = parameters;

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
    
}

