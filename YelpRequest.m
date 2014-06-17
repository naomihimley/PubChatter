//
//  YelpRequest.m
//  PubChatter
//
//  Created by David Warner on 6/17/14.
//  Copyright (c) 2014 Naomi Himley. All rights reserved.
//

#import "YelpRequest.h"

@implementation YelpRequest


-(void)getYelpJSONWithSearch:(NSString *)query andLongitude:(CGFloat)longitude andLatitude:(CGFloat)latitude
{
    id rq = [TDOAuth URLRequestForPath:@"/v2/search" GETParameters:@{@"term": query, @"ll": [NSString stringWithFormat:@"%f,%f", latitude, longitude], @"limit" : @"20", @"sort" : @"1"}
                                  host:@"api.yelp.com"
                           consumerKey:@"LdaQSTTYqZuYXrta5vVAgw"
                        consumerSecret:@"k6KpVPXHSykD8aQXSXqdi7GboMY"
                           accessToken:@"PRBX3m8UH4Q2RmZ-HOTKmjFPLVzmz4UL"
                           tokenSecret:@"ao0diFl7jAe8cDDXnc-O1N-vQm8"];

[NSURLConnection sendAsynchronousRequest:rq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

    NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

    NSArray *yelpBars = [dictionary objectForKey:@"businesses"];

//    NSMutableArray *arrayOfYelpBarItems = [NSMutableArray new];

    for (NSDictionary *dictionary in yelpBars) {
        YelpBar *yelpBar = [[YelpBar alloc] init];
        yelpBar.name = [dictionary objectForKey:@"name"];
//        yelpBar.latitude = [[[dictionary objectForKey:@"region"] objectForKey:@"center"] objectForKey:@"latitude"];

        NSLog(@"%@", yelpBar.name);

//        yelpBar.distanceFromUser =
//        yelpBar.address =
//        yelpBar.latitude =
//        yelpBar.longitude =
//        yelpBar.businessImageURL =
//        yelpBar.businessRatingImageURL =
//        yelpBar.isClosed =
//        [arrayOfYelpBarItems addObject:yelpBar];
    }

}];

}

@end
