//
//  PrivacyPolicyVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "PrivacyPolicyVC.h"

@interface PrivacyPolicyVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *txt_html;

@end

@implementation PrivacyPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *html = @"";
    
    switch (_mType) {
        case p_p_privacyPolicy:
            html = @"<h3>Privacy Policy</h3><p>Brainyapps built the Workbox app as an Open Source app. This SERVICE is provided by Workbox at a graduating monthly cost, depending on the subscription you choose.            This page is used to inform Application visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.                If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.                    The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible on the Workbox application unless otherwise defined in this Privacy Policy.</p>                    <h3>Information Collection And Use</h3>                    <p>For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Drivers Licence, ID or Passport. The information that I request is retained on your device and is not collected by me in any way                        The app does use third party services that may collect information used to identify you.                        Link to privacy policy of third party service providers used by the app                        • Google Play Services (Android)                        • Apple IOS</p>                        <h3>Log Data</h3>                        <p>I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.</p>                        <h3>Cookies</h3>                        <p>Cookies are files with small amount of data that is commonly used an anonymous unique identifier. These are sent to your browser from the website that you visit and are stored on your device internal memory.                        This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collection information and to improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.</p>                        <h3>Service Providers</h3>                        <p>I may employ third-party companies and individuals due to the following reasons:                        • To facilitate our Service;            • To provide the Service on our behalf;            • To perform Service-related services; or            • To assist us in analyzing how our Service is used.            I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.</p>                <h3>Security</h3>                <p>I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.</p>                <h3>Links to Other Sites</h3>                <p>This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.</p>                    <h3>Children's Privacy</h3>                    <p>These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions.</p>                        <h3>Changes To This Privacy Policy</h3>                        <p>I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.</p>                            <h3>Contact Us</h3>                            <p>If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me @ 702-761-9471</p>";
            _lblTitle.text = @"Privacy Policy";
            break;
            
        case p_p_termsAndConditions:
            html = @"<h3>TERMS OF USE AGREEMENT</h3>            <p>This Terms of Use Agreement (“Agreement”) constitutes a legally binding agreement made between you, whether personally or on behalf of an entity (“user” or “you”) and Workbox and its affiliated companies (collectively, “Company” or “we” or “us” or “our”), concerning your access to and use of the Workbox website as well as any other media form, media channel, mobile website or mobile application related or connected thereto (collectively, the “Website”). The Website provides the following service: An application where users can bid on and post jobs. (“Company Services”). Supplemental terms and conditions or documents that may be posted on the Website from time to time, are hereby expressly incorporated into this Agreement by reference.</p>            <p>Company makes no representation that the Website is appropriate or available in other locations other than where it is operated by Company. The information provided on the Website is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject Company to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Website from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.</p>                <p>All users who are minors in the jurisdiction in which they reside (generally under the age of 18) must have the permission of, and be directly supervised by, their parent or guardian to use the Website. If you are a minor, you must have your parent or guardian read and agree to this Agreement prior to you using the Website. Persons under the age of 13 are not permitted to register for the Website or use the Company Services.</p>                    <p>YOU ACCEPT AND AGREE TO BE BOUND BY THIS AGREEMENT BY ACKNOWLEDGING SUCH ACCEPTANCE DURING THE REGISTRATION PROCESS (IF APPLICABLE) AND ALSO BY CONTINUING TO USE THE WEBSITE. IF YOU DO NOT AGREE TO ABIDE BY THIS AGREEMENT, OR TO MODIFICATIONS THAT COMPANY MAY MAKE TO THIS AGREEMENT IN THE FUTURE, DO NOT USE OR ACCESS OR CONTINUE TO USE OR ACCESS THE COMPANY SERVICES OR THE WEBSITE.</p>                    <h3>PURCHASES; PAYMENT</h3>            <p>Company bills you through an online billing account for purchases of products and/or services. You agree to pay Company all charges at the prices then in effect for the products you or other persons using your billing account may purchase, and you authorize Company to charge your chosen payment provider for any such purchases. You agree to make payment using that selected payment method. If you have ordered a product or service that is subject to recurring charges then you consent to our charging your payment method on a recurring basis, without requiring your prior approval from you for each recurring charge until such time as you cancel the applicable product or service. Company reserves the right to correct any errors or mistakes in pricing that it makes even if it has already requested or received Terms of Use (Rev. 133A18A) 2 / 13 payment. Sales tax will be added to the sales price of purchases as deemed required by Company. Company may change prices at any time. All payments shall be in U.S. dollars.</p>    <h3>Purchases</h3>                <h3>REFUND POLICY</h3>                <p>All sales are final and no refunds shall be issued.</p>";
            _lblTitle.text = @"Terms and Conditions";
            break;
            
        case p_p_aboutTheApp:
            html = @"<p>Find potential workout partners or swolemates that already attend your particular exercise facility, whether it may be cardio, power-lifting, cross-fit, yoga, etc...What ever your routine may be, share it with your friends and potential new friends that have a common interest.</p>";
            _lblTitle.text = @"ABOUT THE APP";
            break;
            
        default:
            break;
    }
    
    //    _txt_html.scrollEnabled = NO;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithData: [html dataUsingEncoding:NSUnicodeStringEncoding]
                                                   options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                   documentAttributes: nil
                                                   error: nil
                                                   ];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedString.length)];
    NSRange range = (NSRange){0,[attributedString length]};
    [attributedString enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont* currentFont = value;
        UIFont *replacementFont = nil;
        
        if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            replacementFont = [UIFont boldSystemFontOfSize:20];
        } else {
            replacementFont = [UIFont systemFontOfSize:17];
        }
        
        [attributedString addAttribute:NSFontAttributeName value:replacementFont range:range];
    }];
    _txt_html.attributedText = attributedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}

@end
