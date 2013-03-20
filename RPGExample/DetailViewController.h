//
//  DetailViewController.h
//  RPGExample
//
//  Created by Robin Chou on 3/19/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RPG/RPG.h>

@interface DetailViewController : UIViewController
@property (strong, nonatomic) Character *character;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *characterClassField;
@property (weak, nonatomic) IBOutlet UITextField *monsterNameField;
- (IBAction)updateCharacter:(id)sender;
- (IBAction)deleteCharacter:(id)sender;
- (IBAction)createMonster:(id)sender;

@end
