//
//  NSURL+NSURL_JLRoutes.h
//  JLRoutes
//
//  Created by pair on 4/25/14.
//  Copyright (c) 2014 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (JLRoutes)
-(NSDictionary *)jlr_matchRoute:(NSString *)route;
@end
