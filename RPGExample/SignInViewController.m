//
//  SignInViewController.m
//  RPGExample
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import "SignInViewController.h"
#import <RPG/RPG.h>

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInDidPress:(id)sender {
    [[RPG sharedClient] signInWithEmail:self.emailField.text password:self.passwordField.text completion:^(NSString *apiKey, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        } else {
            // TODO: Take api key and save it to keychain for auto login across launches
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"charactersViewController"];
            [self presentViewController:nc animated:YES completion:nil];
        }
    }];
}
@end
