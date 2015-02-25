//
//  Constants.h
//  turnip
//
//  Created by Per on 1/10/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#ifndef turnip_Constants_h
#define turnip_Constants_h

static double TurnipMetersToMiles(double meters) {
    return meters * 0.000621371;
}

// Parse API key constants:
static NSString * const TurnipParsePostClassName = @"Events";
static NSString * const TurnipParsePostUserKey = @"user";
static NSString * const TurnipParsePostUsernameKey = @"username";
static NSString * const TurnipParsePostTextKey = @"text";
static NSString * const TurnipParsePostTitleKey = @"title";
static NSString * const TurnipParsePostLocationKey = @"location";
static NSString * const TurnipParsePostLocalityKey = @"locality";
static NSString * const TurnipParsePostSubLocalityKey = @"subLocality";
static NSString * const TurnipParsePostThumbnailKey = @"thumbnail";
static NSString * const TurnipParsePostImageOneKey = @"image1";
static NSString * const TurnipParsePostImageTwoKey = @"image2";
static NSString * const TurnipParsePostImageThreeKey = @"image3";
static NSString * const TurnipParsePostPrivateKey = @"private";
static NSString * const TurnipParsePostPublicKey = @"public";
static NSString * const TurnipParsePostPaidKey = @"free";
static NSString * const TurnipParsePostStartDateKey = @"startDate";
static NSString * const TurnipParsePostendDateKey = @"endDate";
static NSString * const TurnipParsePostZipCodeKey = @"zipCode";
static NSString * const TurnipParsePostAddressKey = @"address";
static NSString * const TurnipParsePostDateKey = @"date";
static NSString * const TurnipParsePostEndTimeKey = @"endTime";


static NSString * const TurnipParsePostIdKey = @"objectId";

// Global Notifications
static NSString * const TurnipPartyThrownNotification = @"TurnipPartyThrownNotification";
static NSString * const TurnipAcceptedRequestNotification = @"TurnipAcceptedRequestNotification";
static NSString * const TurnipResetBadgeCountNotification = @"TurnipResetBadgeCountNotification";
static NSString * const TurnipEventDeletedNotification = @"TurnipEventDeletedNotification";
static NSString * const TurnipUserWasAcceptedNotification = @"TurnipUserWasAcceptedNotification";

static double const TurnipDefaultFilterDistance = 1000.0;
static double const TurnipPostMaximumSearchDistance = 20.0;

static NSUInteger const TurnipPostSearchLimit = 20;

#endif
