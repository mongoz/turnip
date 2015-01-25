//
//  PartayConstants.h
//  partay
//
//  Created by Per on 1/10/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#ifndef partay_Constants_h
#define partay_Constants_h

static double PartayMetersToMiles(double meters) {
    return meters * 0.000621371;
}

// Parse API key constants:
static NSString * const PartayParsePostClassName = @"Posts";
static NSString * const PartayParsePostUserKey = @"user";
static NSString * const PartayParsePostUsernameKey = @"username";
static NSString * const PartayParsePostTextKey = @"text";
static NSString * const PartayParsePostTitleKey = @"title";
static NSString * const PartayParsePostLocationKey = @"location";
static NSString * const PartayParsePostLocalityKey = @"locality";
static NSString * const PartayParsePostThumbnailKey = @"thumbnail";
static NSString * const PartayParsePostImageOneKey = @"image1";
static NSString * const PartayParsePostImageTwoKey = @"image1";
static NSString * const PartayParsePostImageThreeKey = @"image1";
static NSString * const PartayParsePostPrivateKey = @"private";
static NSString * const PartayParsePostPublicKey = @"public";
static NSString * const PartayParsePostPaidKey = @"paid";
static NSString * const PartayParsePostStartDateKey = @"startDate";
static NSString * const PartayParsePostendDateKey = @"endDate";

static NSString * const PartayParsePostIdKey = @"objectId";

// Global Notifications
static NSString * const PartayPartyThrownNotification = @"PartayPartyThrownNotification";

static double const PartayDefaultFilterDistance = 1000.0;
static double const PartayPostMaximumSearchDistance = 20.0;

static NSUInteger const PartayPostSearchLimit = 20;

#endif
