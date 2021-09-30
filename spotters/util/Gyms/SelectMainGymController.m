//
//  SelectMainGymController.m
//  Spotters
//
//  Created by Techsviewer on 12/16/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "SelectMainGymController.h"
#import "SelectGymCell.h"
#import "SpecialGymViewController.h"

@interface SelectMainGymController ()<UITableViewDataSource, UITableViewDelegate>
{
    PFUser * me;
    NSMutableArray * additionalGyms;
}
@property (weak, nonatomic) IBOutlet UITableView *_tblData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specialGym_height_const;
@property (weak, nonatomic) IBOutlet UIButton *btnSpecialGym;

@end

@implementation SelectMainGymController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 }
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.isAdditionalMode){
        self.specialGym_height_const.constant = 50.f;
        self.btnSpecialGym.hidden = NO;
        [self.view setNeedsLayout];
    }else{
        self.specialGym_height_const.constant = 0.f;
        self.btnSpecialGym.hidden = YES;
        [self.view setNeedsLayout];
    }
    
    additionalGyms = [NSMutableArray new];
    if(!self.selectedGYMIds)
        self.selectedGYMIds = [NSMutableArray new];
    [self reloadData];
}
- (void) reloadData
{
    me = [PFUser currentUser];
    additionalGyms = [NSMutableArray new];
    if(me){
        NSDate * availableDate = me[FIELD_BUY_DATE];
        availableDate = [availableDate dateByAddingDays:30];
        int buyType = [me[FIELD_BUY_ID] intValue];
        if([availableDate timeIntervalSinceNow] < 0){
            buyType = 0;
        }
        if(buyType > 0){
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_SPECIALGYM];
            [query whereKey:FIELD_SPECIALGYM_TYPE equalTo:[NSNumber numberWithInt:buyType]];
            [query whereKey:FIELD_SPECIALGYM_AVAILABLEDATE greaterThan:[NSDate date]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    additionalGyms = [[NSMutableArray alloc] initWithArray:array];
                    self._tblData.delegate = self;
                    self._tblData.dataSource = self;
                    [self._tblData reloadData];
                }
            }];
        }else{
            self._tblData.delegate = self;
            self._tblData.dataSource = self;
            [self._tblData reloadData];
        }
    }else{
        self._tblData.delegate = self;
        self._tblData.dataSource = self;
        [self._tblData reloadData];
    }
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSpecialGym:(id)sender {
    SpecialGymViewController *vc1 = (SpecialGymViewController *)[Util getUIViewControllerFromStoryBoard:@"SpecialGymViewController"];
    [self.navigationController pushViewController:vc1 animated:YES];
}
- (IBAction)onDOne:(id)sender {
    if(self.selectedGYMIds.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your main GYM"];
    }else{
        [self.delegate SelectMainGymControllerDelegate_didSelected:self.selectedGYMIds  :self.ctrTag];
        if(self.selectedGYMIds.count == 1){
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            NSString * gymId = [self.selectedGYMIds firstObject];
            [Util getGymNameWithId:gymId completionBlock:^(NSString * gynName){
                [SVProgressHUD dismiss];
                [self.delegate SelectMainGymControllerDelegate_didSelectedWithName:gynName :self.ctrTag];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAINGYM_ARRAY.count + additionalGyms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectGymCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SelectGymCell"];
    if(cell){
        if(indexPath.row < MAINGYM_ARRAY.count){
            cell.lblTitle.text = [MAINGYM_ARRAY objectAtIndex:indexPath.row];
            if([self itemIsSelected:(int)indexPath.row]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else{
            PFObject * specialGym = [additionalGyms objectAtIndex:indexPath.row - MAINGYM_ARRAY.count];
            cell.lblTitle.text = specialGym[FIELD_SPECIALGYM_NAME];
            if([self itemStrIsSelected:specialGym.objectId]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectGymCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(indexPath.row < MAINGYM_ARRAY.count){
            [self removeSelecteItem:(int)indexPath.row];
        }else{
            PFObject * specialGym = [additionalGyms objectAtIndex:indexPath.row - MAINGYM_ARRAY.count];
            [self removeStrSelecteItem:specialGym.objectId];
        }
    }else{
        if(self.selectedGYMIds.count == 1){
            self.selectedGYMIds = [[NSMutableArray alloc] init];
            if(indexPath.row < MAINGYM_ARRAY.count){
                [self.selectedGYMIds addObject:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
            }else{
                PFObject * specialGym = [additionalGyms objectAtIndex:indexPath.row - MAINGYM_ARRAY.count];
                [self.selectedGYMIds addObject:specialGym.objectId];
            }
            [tableView reloadData];
            return;
        }
        if(self.selectedGYMIds.count >= self.ableCount){
            [Util showAlertTitle:self title:@"Error" message:[NSString stringWithFormat:@"You can't select more than %d gyms.", self.ableCount]];
            return;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(indexPath.row < MAINGYM_ARRAY.count){
            [self.selectedGYMIds addObject:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
        }else{
            PFObject * specialGym = [additionalGyms objectAtIndex:indexPath.row - MAINGYM_ARRAY.count];
            [self.selectedGYMIds addObject:specialGym.objectId];
        }
    }
}
- (NSArray *) removeObjectFromArray:(NSArray*)array :(NSObject*)item
{
    NSMutableArray * newArray = [NSMutableArray new];
    for(NSObject * subItem in array){
        if(subItem != item){
            [newArray addObject:subItem];
        }
    }
    return newArray;
}
- (void) removeSelecteItem:(int)index
{
    for(NSString * number in self.selectedGYMIds){
        if([number integerValue] == index){
            self.selectedGYMIds = [self removeObjectFromArray:self.selectedGYMIds :number];
        }
    }
}
- (void) removeStrSelecteItem:(NSString*)index
{
    for(NSString * number in self.selectedGYMIds){
        if([number isEqualToString:index]){
            self.selectedGYMIds = [self removeObjectFromArray:self.selectedGYMIds :number];
        }
    }
}
- (BOOL) itemIsSelected:(int)index
{
    for(NSString * number in self.selectedGYMIds){
        if([number isEqualToString:[NSString stringWithFormat:@"%d", index]]){
            return YES;
        }
    }
    return NO;
}
- (BOOL) itemStrIsSelected:(NSString *)objectId
{
    for(NSString * number in self.selectedGYMIds){
        if([number isEqualToString:objectId]){
            return YES;
        }
    }
    return NO;
}
@end
