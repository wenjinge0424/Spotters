//
//  SpecialGymViewController.m
//  Spotters
//
//  Created by Techsviewer on 12/18/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "SpecialGymViewController.h"
#import "SelectGymCell.h"

@interface SpecialGymViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    PFUser * me;
    NSMutableArray * mySpecialGyms;
    int avaiableCount;
    
    
    BOOL canAddMore;
}
@property (weak, nonatomic) IBOutlet UITableView *_tblData;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@end

@implementation SpecialGymViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    [self reloadData];
}
- (void) reloadData
{
    avaiableCount = 0;
    canAddMore = YES;
    self.btnAdd.enabled = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_SPECIALGYM];
    [query whereKey:FIELD_SPECIALGYM_OWNER equalTo:me];
    [query orderByAscending:FIELD_SPECIALGYM_AVAILABLEDATE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            mySpecialGyms = [[NSMutableArray alloc] initWithArray:array];
            for(PFObject * gymItem in mySpecialGyms){
                NSDate * avaiabledate = gymItem[FIELD_SPECIALGYM_AVAILABLEDATE];
                if([avaiabledate timeIntervalSinceNow] > 0){
                    avaiableCount ++;
                }
            }
            
            int purchaseType = [me[FIELD_BUY_ID] intValue];
            if(purchaseType == 1 && avaiableCount >= 5){
                canAddMore = NO;
                self.btnAdd.enabled = NO;
            }else if(purchaseType == 1 && avaiableCount >= 10){
                canAddMore = NO;
                self.btnAdd.enabled = NO;
            }
            
            self._tblData.delegate = self;
            self._tblData.dataSource = self;
            [self._tblData reloadData];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onAdd:(id)sender {
    int purchaseType = [me[FIELD_BUY_ID] intValue];
    if(purchaseType == 1 && avaiableCount >= 5){
        [Util showAlertTitle:self title:@"" message:@"You can't add more special gyms." finish:^{
        }];
        return;
    }else if(purchaseType == 1 && avaiableCount >= 10){
        [Util showAlertTitle:self title:@"" message:@"You can't add more special gyms." finish:^{
        }];
        return;
    }
    
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    SCLTextView *nameView = [alert addTextField:@"title"];
    nameView.tintColor = MAIN_COLOR;
    nameView.secureTextEntry = NO;
    nameView.keyboardType = UIKeyboardTypeNamePhonePad;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Confirm" validationBlock:^BOOL {
        if(nameView.text.length == 0){
            [Util showAlertTitle:self title:@"" message:@"Please input your special gym name." finish:^{
            }];
            return NO;
        }
        NSString * specialGymTitle = nameView.text;
        NSDate * availableDate = me[FIELD_BUY_DATE];
        availableDate = [availableDate dateByAddingDays:30];
        int buyType = [me[FIELD_BUY_ID] intValue];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        PFObject * gym = [PFObject objectWithClassName:PARSE_TABLE_SPECIALGYM];
        gym[FIELD_SPECIALGYM_OWNER] = me;
        gym[FIELD_SPECIALGYM_NAME] = specialGymTitle;
        gym[FIELD_SPECIALGYM_AVAILABLEDATE] = availableDate;
        gym[FIELD_SPECIALGYM_TYPE] = [NSNumber numberWithInt:buyType];
        [gym saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [SVProgressHUD dismiss];
            [self reloadData];
        }];
        
        return YES;
    } actionBlock:^(void) {
        
    }];
    [alert showEdit:self title:@"" subTitle:@"Special Gym name" closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mySpecialGyms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectGymCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SelectGymCell"];
    if(cell){
        cell.btn_makeAvailable.hidden = NO;
        PFObject * gymItem = [mySpecialGyms objectAtIndex:indexPath.row];
        cell.lblTitle.text = gymItem[FIELD_SPECIALGYM_NAME];
        NSDate * availableDate = gymItem[FIELD_SPECIALGYM_AVAILABLEDATE];
        if([availableDate timeIntervalSinceNow] < 0 && canAddMore){
            cell.btn_makeAvailable.enabled = YES;
            cell.btn_makeAvailable.tag = indexPath.row;
            [cell.btn_makeAvailable addTarget:self action:@selector(onEnableGym:) forControlEvents:UIControlEventTouchUpInside];
        }else if([availableDate timeIntervalSinceNow] < 0 && !canAddMore){
            cell.btn_makeAvailable.enabled = NO;
        }else{
            cell.btn_makeAvailable.hidden = YES;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)onEnableGym:(UIButton*)button
{
    int index = (int)button.tag;
    PFObject * gymItem = [mySpecialGyms objectAtIndex:index];
    NSDate * availableDate = me[FIELD_BUY_DATE];
    availableDate = [availableDate dateByAddingDays:30];
    int buyType = [me[FIELD_BUY_ID] intValue];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    gymItem[FIELD_SPECIALGYM_AVAILABLEDATE] = availableDate;
    gymItem[FIELD_SPECIALGYM_TYPE] = [NSNumber numberWithInt:buyType];
    [gymItem saveInBackgroundWithBlock:^(BOOL success, NSError* error){
        [SVProgressHUD dismiss];
        [self reloadData];
    }];
}
@end
