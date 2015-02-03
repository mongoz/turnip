//
//  TurnipUser.m
//  turnip
//
//  Created by Per on 2/1/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TurnipUser.h"

@interface TurnipUser ()

@end

@implementation TurnipUser

- (instancetype) initWithPFObject:(PFObject *)object {
    
    self.objectId = object.objectId;
    self.name = object[@"name"];
    self.birthday = object[@"birthday"];
    self.facebookId = object[@"facebookId"];
    
    [self downloadImage];
    
    return self;
}

- (void) downloadImage {
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.facebookId]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             self.profileImage = [UIImage imageWithData:data];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookImageDownloaded" object:nil];
             });
         }
     }];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject: self.objectId forKey:@"objectId"];
    [encoder encodeObject: self.name forKey:@"name"];
    [encoder encodeObject: self.birthday forKey:@"birthday"];
    [encoder encodeObject: self.facebookId forKey:@"facebookId"];
    [encoder encodeObject: self.profileImage forKey:@"image"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.objectId = [decoder decodeObjectForKey:@"objectId"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.birthday = [decoder decodeObjectForKey:@"birthday"];
        self.facebookId = [decoder decodeObjectForKey:@"facebookId"];
        self.profileImage = [decoder decodeObjectForKey:@"image"];
    }
    return self;
}

@end
