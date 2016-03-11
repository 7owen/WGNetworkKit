//
//  ViewController.m
//  Sample
//
//  Created by 7owen on 16/3/11.
//  Copyright © 2016年 7owen. All rights reserved.
//

#import "ViewController.h"
#import "WGHTTPRequestManager.h"
#import "WGHTTPRequestContext.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *url = @"http://lgw.im/gou-jian-yi-ge-si-you-de-cocoapods-repo/";
    WGHTTPRequestContext *request = [WGHTTPRequestContext createWithURL:url];
    [WGHTTPRequestManagerInstance requestWithRequestContext:request completionHandler:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", responseObject);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
