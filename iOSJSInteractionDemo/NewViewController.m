//
//  NewViewController.m
//  iOSJSInteractionDemo
//
//  Created by macOfEthan on 17/7/24.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "NewViewController.h"
#import "WkWebviewViewController.h"

@interface NewViewController ()

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)jump:(id)sender {
    
    [self presentViewController:[WkWebviewViewController new] animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
