//
//  ViewController.m
//  获取相册权限
//
//  Created by 陈博文 on 16/9/14.
//  Copyright © 2016年 陈博文. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "NSString+WhiteSpace.h"


@interface ViewController ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (IBAction)accessContact:(id)sender {
    
     [self checkContactAuthrizationStatus];
}



- (void)checkContactAuthrizationStatus{
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        
        [self checkBeforeSystemVersion9];
        
    }else{
        
        [self checkAfterSystemVersion9];
    }
    
}

- (void)checkBeforeSystemVersion9{
    
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus == kABAuthorizationStatusNotDetermined)
    {
        
        //获取授权
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion( addressBook, ^(bool granted, CFErrorRef error) {
            
            if (granted)
            {
                [self openContact];
            }
            else
            {
                [self showAlertView];
            }
            
        });
        
        
    }
    else if(authStatus == kABAuthorizationStatusRestricted)
    {
        NSLog(@"用户拒绝");
        [self showAlertView];
    }
    else if (authStatus == kABAuthorizationStatusDenied)
    {
        NSLog(@"用户拒绝");
        [self showAlertView];
    }
    else if (authStatus == kABAuthorizationStatusAuthorized)
    {
        //打开相册
        [self openContact];
    }

    
}
- (void)checkAfterSystemVersion9{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                NSLog(@"授权失败");
            }else {
                NSLog(@"成功授权");
            }
        }];
    }
    else if(status == kABAuthorizationStatusRestricted)
    {
        NSLog(@"用户拒绝");
        [self showAlertView];
    }
    else if (status == kABAuthorizationStatusDenied)
    {
        NSLog(@"用户拒绝");
        [self showAlertView];
    }
    else if (status == kABAuthorizationStatusAuthorized)
    {
        
        [self openContact];
    }

    
}

#pragma mark - openContact
/**
 *  展示没有授权进入通讯录的弹框
 */
- (void)showAlertView{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"通讯录授权未开启" message:@"没有通讯录访问权限，请在设置-隐私-通讯录中进行设置！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"暂不" style:0 handler:nil];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去设置" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingUrl])
        {
            [[UIApplication sharedApplication] openURL:settingUrl];
        }
    }];
    
    [vc addAction:action0];
    [vc addAction:action1];
    [self presentViewController:vc animated:YES completion:nil];
    
}
/**
 *  打开通讯录
 */

- (void)openContact{
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0)
    {

        [self setUpAdressBook];

    }
    else
    {
        [self setUpCNBook];
    }
    
   }


- (void)setUpAdressBook{
    
    // 1.创建选择联系人的控制器
    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
    
    // 2.设置代理
    ppnc.peoplePickerDelegate = self;
    
    //3. 设置属性
    
    //暂时没有去了解,这个可以不设置
    ppnc.addressBook = ABAddressBookCreate();
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        
        //进入个人详情页想展示的属性,如果不设置,默认展示所有属性
        //kABPersonPhoneProperty这些属性可以去ABPerson.h这个类去查,太多就不列出来
        ppnc.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];//只是展示电话号码
        
        // 过滤能选中的联系人,不符合条件的会变成灰色不可选;CNMutableContact这个类中可以查询CNMutableContact等属性,这里就不列出来
        ppnc.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];//让有 email 的对象才可以选中
        
        // 默认是 true,选中通讯录某个人时候,是否退出通讯录返回 app,false 就会进入个人详情页
        
        //如果没有设置该属性,但实现peoplePickerNavigationController:didSelectPerson这个方法,就会退出通讯录返回 app
        
        //如果没有设置该属性,但实现peoplePickerNavigationController:didSelectPerson:identifier:这个方法,会进入个人详情
        
        // 如果设置成 false,就会进入个人详情页,点击属性就会进行相应操作;例如:点击电话就会打电话
        //  如果设置成 false,实现peoplePickerNavigationController:didSelectPerson:identifier:这个方法;点击属性会 dismiss,返回 app--apple 的说明没有说这种情况,注意使用
        
        //            ppnc.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
        
        
        //默认是 true,如果设置成 false,就会进入个人详情页,点击属性就会进行相应操作;例如:`点击电话就会打电话`
        //            ppnc.predicateForSelectionOfProperty = [NSPredicate predicateWithValue:false];
        
    }
    
    
    // 4.弹出控制器
    [self presentViewController:ppnc animated:YES completion:nil];
}

- (void)setUpCNBook{
    
    CNContactPickerViewController *pickerVC = [[CNContactPickerViewController alloc] init];
    //只是展示电话号码,email 等不展示
    pickerVC.displayedPropertyKeys = [NSArray arrayWithObject:CNContactPhoneNumbersKey];
    //让有 email 的对象才可以选中
    pickerVC.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
    //选中联系人是否返回
//    pickerVC.predicateForSelectionOfContact =  [NSPredicate predicateWithValue:false];
    //选中属性是否返回
//    pickerVC.predicateForSelectionOfProperty = [NSPredicate predicateWithValue:false];
    pickerVC.delegate = self;
    [self presentViewController:pickerVC animated:YES completion:nil];

}

#pragma mark - <ABPeoplePickerNavigationControllerDelegate>
// 当用户选中某一个联系人时会执行该方法,并且选中联系人后会直接退出控制器
//- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
//{
//  
//}

// 当用户选中某一个联系人的某一个属性时会执行该方法,并且选中属性后会退出控制器
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{

    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);

    NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, 0);

    //
    CFRelease(phones);

    NSLog(@"person:%@",person);
    NSLog(@"property:%zd",property);
    NSLog(@"identifier:%zd",identifier);
    
    NSLog(@"%@",phoneValue.filterWhiteSpace.filterMinus);
//    如果不是数字就会返回0
//    电话号码默认是11位
//    如果电话号码错误,就使用直接弹框,支付宝
    if (phoneValue.filterWhiteSpace.filterMinus.length != 11 || phoneValue.filterWhiteSpace.filterMinus.intValue)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            NSLog(@"请输入正确的电话号码");
        });

    }

}



- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CNContactPickerDelegate

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
//    
//}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{

    NSLog(@"key = %@",contactProperty.key);
    NSLog(@"value = %@",contactProperty.value);
    
    CNPhoneNumber *phoneString = contactProperty.value;

    NSLog(@"phoneString = %@",phoneString.stringValue);

    

}


//以下两个是设置多选时候使用的,如果实现其中一个方法,单选就不能实现
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts{
//    
//}
//
//
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty*> *)contactProperties{
//    
//    
//}

//- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
