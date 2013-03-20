//
//  DetailViewController.m
//  RPGExample
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import "DetailViewController.h"
#import <RPG/RPG.h>
#import "AppDelegate.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureView
{
    [self setTitle:self.character.characterClass];
    [self.nameField setText:self.character.name];
    [self.characterClassField setText:self.character.characterClass];
}

- (IBAction)updateCharacter:(id)sender {
    self.character.name = self.nameField.text;
    self.character.characterClass = self.characterClassField.text;
    
    [[RPG sharedClient] putCharacter:self.character completion:^(Character *character, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        } else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)deleteCharacter:(id)sender {
    [[RPG sharedClient] deleteCharacter:self.character completion:^(Character *character, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        } else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)createMonster:(id)sender {
    [[RPG sharedClient] createRandomMonster:^(Monster *monster, NSError *error) {
        self.monsterNameField.text = monster.name;
    }];
}
@end
