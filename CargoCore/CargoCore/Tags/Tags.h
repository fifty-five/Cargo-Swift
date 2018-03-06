//
//  Tags.h
//  Cargo
//
//  Created by Julien Gil on 06/03/2017.
//  Copyright © 2017 François K. All rights reserved.
//

#ifndef Tags_h
#define Tags_h

#import <Foundation/Foundation.h>
#import "GoogleTagManager/GoogleTagManager.h"

@interface Tags : NSObject <TAGCustomFunction>

- (NSObject*)executeWithParameters:(NSDictionary*)parameters;

@end


#endif /* Tags_h */
