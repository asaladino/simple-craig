//
//  CraigsListRepository.m
//  SimpleCraig
//
//  Created by Adam Saladino on 7/16/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "CraigsListRepository.h"
#import "IGHTMLQuery.h"
#import "Category.h"

#define kUserAgentString @"Mozilla/5.0 (Windows; U; Windows NT 6.1; tr-TR) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27"

@implementation CraigsListRepository

- (id)init {
    self = [super init];
    if (self) {
        self.areas = [[NSMutableArray alloc] init];
        self.categories = [[NSMutableArray alloc] init];
        self.types = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) save: (Post *) post {
    self.post = post;
    [self findAreas];
}

#pragma mark - Connection requests

/**
 * Load the areas list. Receives a list of areas in a form.
 *
 * https://post.craigslist.org
 *
 */
- (void) findAreas {
    self.currentState = CraigsListRepositoryStateFindAreas;
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://post.craigslist.org"]];
    [self.request setValue:kUserAgentString forHTTPHeaderField:@"User-Agent"];
    self.responseData = [[NSMutableData alloc] init];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

/**
 * This is the area post form, it posts to the areas page to set the area. The response is a list of
 * types to select from.
 *
 * ==== The Request Headers ====
 * https://post.craigslist.org/k/eFhNkmN14xGHEA42sf-0Vg/PmUUW?s=area
 * n=710&cryptedStepCheck=U2FsdGVkX183NjEzNzYxM7WavOEgxqd5QBP8V3mt5VqbT5S3-SrpUVS1wzMz8sZV&go=Continue
 *
 */
- (void) setAreaAndFindTypes {
    self.currentState = CraigsListRepositoryStateSetAreaAndFindTypes;
    [self sendPostRequest:self.areaFormAction withPostString:[self setAreaAndFindTypesPostString]];
}

- (NSString *) setAreaAndFindTypesPostString {
    return [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&go=Continue", self.areaInputName, self.post.currentArea, self.areaInputHiddenName, self.areaInputHiddenValue];
}

/**
 * This is the types post form, it posts to the types page to set the type. The response is a list of categories to
 * select from.
 *
 * ==== The Request Headers ====
 * https://post.craigslist.org/k/eFhNkmN14xGHEA42sf-0Vg/PmUUW?s=type
 * id=fso&cryptedStepCheck=U2FsdGVkX18yMTkyNTIxOV-c2zaSqz8feiE3IYdu6AAWFLHlNNsA0G0PFARzyCKX
 *
 */
- (void) setTypeAndFindCategories {
    self.currentState = CraigsListRepositoryStateSetTypeAndFindCategories;
    [self sendPostRequest:self.typeFormAction withPostString:[self setCategoryAndLoadInformationFormPostString]];
}

- (NSString *) setTypeAndFindCategoriesPostString {
    return [[NSString alloc] initWithFormat:@"%@=%@&%@=%@", self.typeInputName, self.post.currentType, self.typeInputHiddenName, self.typeInputHiddenValue];
}

/**
 * This is the categories post form, it posts to the categories page to set the category. The response is a form
 * for setting the post information.
 
 * ==== The Request Headers ====
 * https://post.craigslist.org/k/eFhNkmN14xGHEA42sf-0Vg/PmUUW?s=cat
 * id=42&cryptedStepCheck=U2FsdGVkX183NjEzNzYxM16e2zj7OauQ-TH7cMBD_QzpDUwap4ykOuKtXv7o_o5a
 *
 */
- (void) setCategoryAndLoadInformationForm {
    self.currentState = CraigsListRepositoryStateSetCategoryLoadInformationForm;
    [self sendPostRequest:self.categoryFormAction withPostString:[self setCategoryAndLoadInformationFormPostString]];
}

- (NSString *) setCategoryAndLoadInformationFormPostString {
    return [[NSString alloc] initWithFormat:@"%@=%@&%@=%@", self.categoryInputName, self.post.currentCategory, self.categoryInputHiddenName, self.categoryInputHiddenValue];
}


/**
 * This the post information form, it sets the post information. The response is a form to set the image.
 *
 * id2 is a javascript input field that gets that gets appended on load and measures the dimensions of the browser.
 *
 * https://post.craigslist.org/k/eFhNkmN14xGHEA42sf-0Vg/PmUUW?s=edit
 * id2=1169x979X1169x482X1920x1080&browserinfo=&contact_method=0&contact_phone=&contact_name=&FromEMail=adam.saladino%40icloud.com&ConfirmEMail=adam.saladino%40icloud.com&Privacy=C&PostingTitle=Yard+Boulder&GeographicArea=east+athens&postal=&PostingBody=500+lbs+rock+that+needs+to+be+gone.&xstreet0=&xstreet1=&city=&region=&postal=&go=Continue&cryptedStepCheck=U2FsdGVkX183MzQ5NzM0OWF6Dz_SR9DwsxIzrQFXPi4IB8usryMntrcaRA3ielck
 * browserinfo=%7B%0A%09%22plugins%22%3A%20%22Plugin%200%3A%20Coupons%20Inc.%2C%20Coupon%20Printing%20Plugin%2C%201.1.10%3B%20Coupons%20Inc.%2C%20Coupon%20Printing%20Plugin%3B%20CouponPrinter-FireFox_v2.plugin%3B%20%28Coupons%20Inc.%2C%20Coupon%20Printer%3B%20application/couponsinc-printer-plugin%3B%20%29%20%28Coupons%20Inc.%2C%20Coupon%20Printer%20v401%3B%20application/couponsinc-moz-printer-plugin-v401%3B%20%29.%20Plugin%201%3A%20Default%20Browser%20Helper%3B%20Provides%20information%20about%20the%20default%20web%20browser%3B%20Default%20Browser.plugin%3B%20%28Provides%20information%20about%20the%20default%20web%20browser%3B%20application/apple-default-browser%3B%20%29.%20Plugin%202%3A%20Google%20Earth%20Plug-in%3B%20The%20Google%20Earth%20Plugin%20allows%20you%20to%20view%203D%20imagery%20and%20terrain%20in%20your%20web%20browser.%3B%20Google%20Earth%20Web%20Plug-in.plugin%3B%20%28Google%20Earth%20browser%20plugin%3B%20application/geplugin%3B%20%29.%20Plugin%203%3A%20Google%20Earth%20Plug-in%3B%20The%20Google%20Earth%20Plugin%20allows%20you%20to%20view%203D%20imagery%20and%20terrain%20in%20your%20web%20browser.%3B%20Google%20Earth%20Web%20Plug-in.plugin%3B%20%28Google%20Earth%20browser%20plugin%3B%20application/geplugin%3B%20%29.%20Plugin%204%3A%20Google%20Talk%20Plugin%20Video%20Accelerator%3B%20Google%20Talk%20Plugin%20Video%20Accelerator%20version%3A0.1.44.29%3B%20npgtpo3dautoplugin.plugin%3B%20%28Google%20Talk%20Plugin%20Video%20Accelerator%20Type%3B%20application/vnd.gtpo3d.auto%3B%20%29.%20Plugin%205%3A%20Google%20Talk%20Plugin%20Video%20Renderer%3B%20Version%204.9.1.16010%3B%20o1dbrowserplugin.plugin%3B%20%28Google%20Talk%20Plugin%20Video%20Renderer%3B%20application/o1d%3B%20o1d%29.%20Plugin%206%3A%20Google%20Talk%20Plugin%3B%20Version%204.9.1.16010%3B%20googletalkbrowserplugin.plugin%3B%20%28Google%20voice%20and%20video%20chat%3B%20application/googletalk%3B%20googletalk%29.%20Plugin%207%3A%20Java%20Applet%20Plug-in%3B%20Displays%20Java%20applet%20content%2C%20or%20a%20placeholder%20if%20Java%20is%20not%20installed.%3B%20JavaAppletPlugin.plugin%3B%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bdeploy%3D10.45.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bjavafx%3D2.2.45%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.3%3B%20%29%20%28Java%20applet%3B%20application/x-java-vm%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-vm-npruntime%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bjpi-version%3D1.7.0_45%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.7%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.2%3B%20%29%20%28Basic%20Java%20Applets%3B%20application/x-java-applet%3B%20javaapplet%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.3%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.6%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.3.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.5%3B%20%29.%20Plugin%208%3A%20Microsoft%20Office%20Live%20Plug-in%3B%20Office%20Live%20Update%20v1.0%3B%20OfficeLiveBrowserPlugin.plugin%3B%20%28Office%20Live%20Update%20v1.0%3B%20application/officelive%3B%20%29.%20Plugin%209%3A%20Picasa%3B%20Picasa%20plugin.%3B%20Picasa.plugin%3B%20%283.1%3B%20application/x-picasa-detect%3B%20picasa%29.%20Plugin%2010%3A%20QuickTime%20Plug-in%207.7.3%3B%20The%20QuickTime%20Plugin%20allows%20you%20to%20view%20a%20wide%20variety%20of%20multimedia%20content%20in%20web%20pages.%20For%20more%20information%2C%20visit%20the%20%3CA%20HREF%3Dhttp%3A//www.apple.com/quicktime%3EQuickTime%3C/A%3E%20Web%20site.%3B%20QuickTime%20Plugin.plugin%3B%20%28Video%20For%20Windows%3B%20video/x-msvideo%3B%20avi%2Cvfw%29%20%28MP3%20audio%3B%20audio/mp3%3B%20mp3%2Cswa%29%20%28MP3%20audio%3B%20audio/mpeg3%3B%20mp3%2Cswa%29%20%283GPP2%20media%3B%20video/3gpp2%3B%203g2%2C3gp2%29%20%28CAF%20audio%3B%20audio/x-caf%3B%20caf%29%20%28MPEG%20audio%3B%20audio/mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1a%2Cmp2%2Cmpm%2Cmpa%2Cm2a%2Cmp3%2Cswa%29%20%28QuickTime%20Movie%3B%20video/quicktime%3B%20mov%2Cqt%2Cmqv%29%20%28MP3%20audio%3B%20audio/x-mpeg3%3B%20mp3%2Cswa%29%20%28MPEG-4%20media%3B%20video/mp4%3B%20mp4%29%20%28SDP%20stream%20descriptor%3B%20application/x-sdp%3B%20sdp%29%20%28WAVE%20audio%3B%20audio/wav%3B%20wav%2Cbwf%29%20%28Video%20For%20Windows%3B%20video/avi%3B%20avi%2Cvfw%29%20%28AC3%20audio%3B%20audio/x-ac3%3B%20ac3%29%20%28MPEG-4%20media%3B%20audio/mp4%3B%20mp4%29%20%28Video%3B%20video/x-m4v%3B%20m4v%29%20%28SDP%20stream%20descriptor%3B%20application/sdp%3B%20sdp%29%20%28WAVE%20audio%3B%20audio/x-wav%3B%20wav%2Cbwf%29%20%28AIFF%20audio%3B%20audio/x-aiff%3B%20aiff%2Caif%2Caifc%2Ccdda%29%20%28MPEG%20media%3B%20video/x-mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1v%2Cm1a%2Cm75%2Cm15%2Cmp2%2Cmpm%2Cmpv%2Cmpa%29%20%283GPP%20media%3B%20video/3gpp%3B%203gp%2C3gpp%29%20%28Video%20For%20Windows%3B%20video/msvideo%3B%20avi%2Cvfw%29%20%28MPEG%20audio%3B%20audio/x-mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1a%2Cmp2%2Cmpm%2Cmpa%2Cm2a%2Cmp3%2Cswa%29%20%28QUALCOMM%20PureVoice%20audio%3B%20audio/vnd.qcelp%3B%20qcp%2Cqcp%29%20%28MP3%20audio%3B%20audio/x-mp3%3B%20mp3%2Cswa%29%20%28RTSP%20stream%20descriptor%3B%20application/x-rtsp%3B%20rtsp%2Crts%29%20%28AMR%20audio%3B%20audio/AMR%3B%20AMR%29%20%28SD%20video%3B%20video/sd-video%3B%20sdv%29%20%28AIFF%20audio%3B%20audio/aiff%3B%20aiff%2Caif%2Caifc%2Ccdda%29%20%28MPEG%20media%3B%20video/mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1v%2Cm1a%2Cm75%2Cm15%2Cmp2%2Cmpm%2Cmpv%2Cmpa%29%20%283GPP2%20media%3B%20audio/3gpp2%3B%203g2%2C3gp2%29%20%28AAC%20audio%3B%20audio/aac%3B%20aac%2Cadts%29%20%28AC3%20audio%3B%20audio/ac3%3B%20ac3%29%20%28AAC%20audio%20book%3B%20audio/x-m4b%3B%20m4b%29%20%28AAC%20audio%3B%20audio/x-m4p%3B%20m4p%29%20%28GSM%20audio%3B%20audio/x-gsm%3B%20gsm%29%20%28AMC%20media%3B%20application/x-mpeg%3B%20amc%29%20%28AAC%20audio%3B%20audio/x-aac%3B%20aac%2Cadts%29%20%28uLaw/AU%20audio%3B%20audio/basic%3B%20au%2Csnd%2Culw%29%20%28AAC%20audio%3B%20audio/x-m4a%3B%20m4a%29%20%283GPP%20media%3B%20audio/3gpp%3B%203gp%2C3gpp%29.%20Plugin%2011%3A%20Shockwave%20Flash%3B%20Shockwave%20Flash%2011.9%20r900%3B%20Flash%20Player.plugin%3B%20%28Shockwave%20Flash%3B%20application/x-shockwave-flash%3B%20swf%29%20%28FutureSplash%20Player%3B%20application/futuresplash%3B%20spl%29.%20Plugin%2012%3A%20Silverlight%20Plug-In%3B%205.1.20913.0%3B%20Silverlight.plugin%3B%20%28Microsoft%20Silverlight%3B%20application/x-silverlight%3B%20xaml%29%20%28Microsoft%20Silverlight%3B%20application/x-silverlight-2%3B%20xaml%29.%20Plugin%2013%3A%20iPhotoPhotocast%3B%20iPhoto6%3B%20iPhotoPhotocast.plugin%3B%20%28iPhoto%20700%3B%20application/photo%3B%20%29.%20%22%2C%0A%09%22timezone%22%3A%20300%2C%0A%09%22video%22%3A%20%221920x1080x24%22%2C%0A%09%22supercookies%22%3A%20%22DOM%20localStorage%3A%20Yes%2C%20DOM%20sessionStorage%3A%20Yes%2C%20IE%20userData%3A%20No%22%0A%7D
 */
- (void) setPostInformationAndLoadImageForm {
    self.currentState = CraigsListRepositoryStateSetPostInformationAndLoadImageForm;
    [self sendPostRequest:self.informationPostFormAction withPostString:[self setPostInformationAndLoadImageFormPostString]];
}

- (NSString *) setPostInformationAndLoadImageFormPostString {
    // Stats or browser identifiers?
    NSString *id2 = @"1169x979X1169x482X1920x1080";
    NSString *browserinfo = @"%7B%0A%09%22plugins%22%3A%20%22Plugin%200%3A%20Coupons%20Inc.%2C%20Coupon%20Printing%20Plugin%2C%201.1.10%3B%20Coupons%20Inc.%2C%20Coupon%20Printing%20Plugin%3B%20%28Coupons%20Inc.%2C%20Coupon%20Printer%3B%20application/couponsinc-printer-plugin%3B%20%29%20%28Coupons%20Inc.%2C%20Coupon%20Printer%20v401%3B%20application/couponsinc-moz-printer-plugin-v401%3B%20%29.%20Plugin%201%3A%20Default%20Browser%20Helper%3B%20Provides%20information%20about%20the%20default%20web%20browser%3B%20Default%20Browser.plugin%3B%20%28Provides%20information%20about%20the%20default%20web%20browser%3B%20application/apple-default-browser%3B%20%29.%20Plugin%202%3A%20Google%20Earth%20Plug-in%3B%20The%20Google%20Earth%20Plugin%20allows%20you%20to%20view%203D%20imagery%20and%20terrain%20in%20your%20web%20browser.%3B%20Google%20Earth%20Web%20Plug-in.plugin%3B%20%28Google%20Earth%20browser%20plugin%3B%20application/geplugin%3B%20%29.%20Plugin%203%3A%20Google%20Earth%20Plug-in%3B%20The%20Google%20Earth%20Plugin%20allows%20you%20to%20view%203D%20imagery%20and%20terrain%20in%20your%20web%20browser.%3B%20Google%20Earth%20Web%20Plug-in.plugin%3B%20%28Google%20Earth%20browser%20plugin%3B%20application/geplugin%3B%20%29.%20Plugin%204%3A%20Google%20Talk%20Plugin%20Video%20Accelerator%3B%20Google%20Talk%20Plugin%20Video%20Accelerator%20version%3A0.1.44.29%3B%20npgtpo3dautoplugin.plugin%3B%20%28Google%20Talk%20Plugin%20Video%20Accelerator%20Type%3B%20application/vnd.gtpo3d.auto%3B%20%29.%20Plugin%205%3A%20Google%20Talk%20Plugin%20Video%20Renderer%3B%20Version%204.9.1.16010%3B%20o1dbrowserplugin.plugin%3B%20%28Google%20Talk%20Plugin%20Video%20Renderer%3B%20application/o1d%3B%20o1d%29.%20Plugin%206%3A%20Google%20Talk%20Plugin%3B%20Version%204.9.1.16010%3B%20googletalkbrowserplugin.plugin%3B%20%28Google%20voice%20and%20video%20chat%3B%20application/googletalk%3B%20googletalk%29.%20Plugin%207%3A%20Java%20Applet%20Plug-in%3B%20Displays%20Java%20applet%20content%2C%20or%20a%20placeholder%20if%20Java%20is%20not%20installed.%3B%20JavaAppletPlugin.plugin%3B%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bdeploy%3D10.45.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bjavafx%3D2.2.45%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.3%3B%20%29%20%28Java%20applet%3B%20application/x-java-vm%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-vm-npruntime%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bjpi-version%3D1.7.0_45%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.7%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.2%3B%20%29%20%28Basic%20Java%20Applets%3B%20application/x-java-applet%3B%20javaapplet%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.1.3%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.6%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.4.2%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.3.1%3B%20%29%20%28Java%20applet%3B%20application/x-java-applet%3Bversion%3D1.5%3B%20%29.%20Plugin%208%3A%20Microsoft%20Office%20Live%20Plug-in%3B%20Office%20Live%20Update%20v1.0%3B%20OfficeLiveBrowserPlugin.plugin%3B%20%28Office%20Live%20Update%20v1.0%3B%20application/officelive%3B%20%29.%20Plugin%209%3A%20Picasa%3B%20Picasa%20plugin.%3B%20Picasa.plugin%3B%20%283.1%3B%20application/x-picasa-detect%3B%20picasa%29.%20Plugin%2010%3A%20QuickTime%20Plug-in%207.7.3%3B%20The%20QuickTime%20Plugin%20allows%20you%20to%20view%20a%20wide%20variety%20of%20multimedia%20content%20in%20web%20pages.%20For%20more%20information%2C%20visit%20the%20%3CA%20HREF%3Dhttp%3A//www.apple.com/quicktime%3EQuickTime%3C/A%3E%20Web%20site.%3B%20QuickTime%20Plugin.plugin%3B%20%28Video%20For%20Windows%3B%20video/x-msvideo%3B%20avi%2Cvfw%29%20%28MP3%20audio%3B%20audio/mp3%3B%20mp3%2Cswa%29%20%28MP3%20audio%3B%20audio/mpeg3%3B%20mp3%2Cswa%29%20%283GPP2%20media%3B%20video/3gpp2%3B%203g2%2C3gp2%29%20%28CAF%20audio%3B%20audio/x-caf%3B%20caf%29%20%28MPEG%20audio%3B%20audio/mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1a%2Cmp2%2Cmpm%2Cmpa%2Cm2a%2Cmp3%2Cswa%29%20%28QuickTime%20Movie%3B%20video/quicktime%3B%20mov%2Cqt%2Cmqv%29%20%28MP3%20audio%3B%20audio/x-mpeg3%3B%20mp3%2Cswa%29%20%28MPEG-4%20media%3B%20video/mp4%3B%20mp4%29%20%28SDP%20stream%20descriptor%3B%20application/x-sdp%3B%20sdp%29%20%28WAVE%20audio%3B%20audio/wav%3B%20wav%2Cbwf%29%20%28Video%20For%20Windows%3B%20video/avi%3B%20avi%2Cvfw%29%20%28AC3%20audio%3B%20audio/x-ac3%3B%20ac3%29%20%28MPEG-4%20media%3B%20audio/mp4%3B%20mp4%29%20%28Video%3B%20video/x-m4v%3B%20m4v%29%20%28SDP%20stream%20descriptor%3B%20application/sdp%3B%20sdp%29%20%28WAVE%20audio%3B%20audio/x-wav%3B%20wav%2Cbwf%29%20%28AIFF%20audio%3B%20audio/x-aiff%3B%20aiff%2Caif%2Caifc%2Ccdda%29%20%28MPEG%20media%3B%20video/x-mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1v%2Cm1a%2Cm75%2Cm15%2Cmp2%2Cmpm%2Cmpv%2Cmpa%29%20%283GPP%20media%3B%20video/3gpp%3B%203gp%2C3gpp%29%20%28Video%20For%20Windows%3B%20video/msvideo%3B%20avi%2Cvfw%29%20%28MPEG%20audio%3B%20audio/x-mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1a%2Cmp2%2Cmpm%2Cmpa%2Cm2a%2Cmp3%2Cswa%29%20%28QUALCOMM%20PureVoice%20audio%3B%20audio/vnd.qcelp%3B%20qcp%2Cqcp%29%20%28MP3%20audio%3B%20audio/x-mp3%3B%20mp3%2Cswa%29%20%28RTSP%20stream%20descriptor%3B%20application/x-rtsp%3B%20rtsp%2Crts%29%20%28AMR%20audio%3B%20audio/AMR%3B%20AMR%29%20%28SD%20video%3B%20video/sd-video%3B%20sdv%29%20%28AIFF%20audio%3B%20audio/aiff%3B%20aiff%2Caif%2Caifc%2Ccdda%29%20%28MPEG%20media%3B%20video/mpeg%3B%20mpeg%2Cmpg%2Cm1s%2Cm1v%2Cm1a%2Cm75%2Cm15%2Cmp2%2Cmpm%2Cmpv%2Cmpa%29%20%283GPP2%20media%3B%20audio/3gpp2%3B%203g2%2C3gp2%29%20%28AAC%20audio%3B%20audio/aac%3B%20aac%2Cadts%29%20%28AC3%20audio%3B%20audio/ac3%3B%20ac3%29%20%28AAC%20audio%20book%3B%20audio/x-m4b%3B%20m4b%29%20%28AAC%20audio%3B%20audio/x-m4p%3B%20m4p%29%20%28GSM%20audio%3B%20audio/x-gsm%3B%20gsm%29%20%28AMC%20media%3B%20application/x-mpeg%3B%20amc%29%20%28AAC%20audio%3B%20audio/x-aac%3B%20aac%2Cadts%29%20%28uLaw/AU%20audio%3B%20audio/basic%3B%20au%2Csnd%2Culw%29%20%28AAC%20audio%3B%20audio/x-m4a%3B%20m4a%29%20%283GPP%20media%3B%20audio/3gpp%3B%203gp%2C3gpp%29.%20Plugin%2011%3A%20Shockwave%20Flash%3B%20Shockwave%20Flash%2011.9%20r900%3B%20Flash%20Player.plugin%3B%20%28Shockwave%20Flash%3B%20application/x-shockwave-flash%3B%20swf%29%20%28FutureSplash%20Player%3B%20application/futuresplash%3B%20spl%29.%20Plugin%2012%3A%20Silverlight%20Plug-In%3B%205.1.20913.0%3B%20Silverlight.plugin%3B%20%28Microsoft%20Silverlight%3B%20application/x-silverlight%3B%20xaml%29%20%28Microsoft%20Silverlight%3B%20application/x-silverlight-2%3B%20xaml%29.%20Plugin%2013%3A%20iPhotoPhotocast%3B%20iPhoto6%3B%20iPhotoPhotocast.plugin%3B%20%28iPhoto%20700%3B%20application/photo%3B%20%29.%20%22%2C%0A%09%22timezone%22%3A%20300%2C%0A%09%22video%22%3A%20%221920x1080x24%22%2C%0A%09%22supercookies%22%3A%20%22DOM%20localStorage%3A%20Yes%2C%20DOM%20sessionStorage%3A%20Yes%2C%20IE%20userData%3A%20No%22%0A%7D";
    return [[NSString alloc] initWithFormat:@"id2=%@&browserinfo=%@&contact_method=0&contact_phone=&contact_name=&FromEMail=%@&ConfirmEMail=%@&Privacy=C&PostingTitle=%@&GeographicArea=%@&postal=&PostingBody=%@&xstreet0=&xstreet1=&city=&region=&postal=&go=Continue&%@=%@",
            id2,
            browserinfo,
            self.post.email,
            self.post.email,
            self.post.title,
            self.post.specificLocation,
            self.post.description,
            self.informationPostInputHiddenName,
            self.informationPostInputHiddenValue];
}

/**
 * When we post an image
 * https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJz
 * cryptedStepCheck=U2FsdGVkX18xOTQ1MDE5NEAD71NRxn4CCRBdhcU3Ikhv0WIn7uIJm3X3lIvOedEB_SuqkKO6fZA&a=Add&go=add+image
 *
 */
- (void) addImage {
    self.currentState = CraigsListRepositoryStateSetPostInformationAndLoadImageForm;
    // create request
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageFormAction]];
    [self.request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [self.request setHTTPShouldHandleCookies:NO];
    [self.request setTimeoutInterval:30];
    [self.request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [self.request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    NSDictionary *params = @{self.imageInputHiddenName: self.imageInputHiddenValue, @"a": @"Add", @"go": @"add+image"};
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation([self.post.currentImages firstObject], 1.0);
    [self.post.currentImages removeObjectAtIndex:0];
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [self.request setHTTPBody:body];
    self.responseData = [[NSMutableData alloc] init];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

/**
 * When we are done with uploading images, we post to the preview page for review. This post response should return
 * a review page.
 *
 * https://post.craigslist.org/k/UiPAwlx14xG3EmeIbjF5pg/cScbl?s=preview
 * cryptedStepCheck=U2FsdGVkX18xNDQxNTE0NM1-7YfpkCIcKtHRsFBKogstrDmlV1wxrqS8TD01rnoZA9EOcm9r1JA&a=fin&go=Done+with+Images
 *
 */
- (void) setWithImagesLoadFinalReview {
    self.currentState = CraigsListRepositoryStateSetPostFinishedWithImages;
    [self sendPostRequest:self.doneWithImageFormAction withPostString:[self setWithImagesLoadFinalReviewPostString]];
}

- (NSString *) setWithImagesLoadFinalReviewPostString {
    return [[NSString alloc] initWithFormat:@"%@=%@&a=fin&go=Done+with+Images", self.doneWithImageInputHiddenName, self.doneWithImageInputHiddenValue];
}


/**
 * We are done with the post, just submit it.
 *
 * https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ
 * cryptedStepCheck=U2FsdGVkX18xNDQxNTE0NM1-7YfpkCIcKtHRsFBKogstrDmlV1wxrqS8TD01rnoZA9EOcm9r1JA&continue=y&go=Continue
 *
 <input type="hidden" name="cryptedStepCheck" value= "U2FsdGVkX18yMjMwOTIyM3mXu5rrSYcSriWKLubXTKoteEqhma_g9FISNe0QeO45PC5gZDnVCYg">
 <input type="hidden" name="continue" value="y">
 <button class="button" type="submit" tabindex="1" name="go" value="Continue">publish</button>
 */
- (void) submitFinalPost {
    self.currentState = CraigsListRepositoryStateSubmitFinalPost;
    [self sendPostRequest:self.finishFormAction withPostString:[self submitFinalPostPostString]];
}

- (NSString *) submitFinalPostPostString {
    return [[NSString alloc] initWithFormat:@"%@=%@&continue=y&go=Continue", self.finishInputHiddenName, self.finishInputHiddenValue];
}


#pragma mark - post message helpers

- (void) sendPostRequest: (NSString *) url withPostString: (NSString *) postString {
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.request setHTTPMethod:@"POST"];
    [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [self.request setValue:kUserAgentString forHTTPHeaderField:@"User-Agent"];
    
    [self.request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    self.responseData = [[NSMutableData alloc] init];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

#pragma mark - NSURLConnection Delegate Methods

/**
 * Append the new data to the instance variable you declared
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

/**
 * Return nil to indicate not necessary to store a cached response for this connection
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

/**
 * Parse the html
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *html = [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
    switch (self.currentState) {
        case CraigsListRepositoryStateFindAreas:
            [self parseAreaResponse:connection orHtml:html];
            break;
        case CraigsListRepositoryStateSetAreaAndFindTypes:
            [self parseTypeResponse:connection orHtml:html];
            break;
        case CraigsListRepositoryStateSetTypeAndFindCategories:
            [self parseCategoryResponse:connection orHtml:html];
            break;
        case CraigsListRepositoryStateSetCategoryLoadInformationForm:
            [self parsePostListingResponse:connection orHtml:html];
            break;
        case CraigsListRepositoryStateSetPostInformationAndLoadImageForm:
            [self parseImageForm: connection orHtml:html];
            break;
        case CraigsListRepositoryStateSetPostFinishedWithImages:
            [self parseDoneWithImages: connection orHtml:html];
            break;
        case CraigsListRepositoryStateSubmitFinalPost:
            [self parseSubmitFinalPost: connection orHtml:html];
            break;
    }
}

/**
 * Report any connection errors.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    switch (self.currentState) {
        case CraigsListRepositoryStateFindAreas:
            [self.delegate craigsListRepositoryFindAreasError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSetAreaAndFindTypes:
            [self.delegate craigsListRepositorySetAreaAndFindTypesError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSetTypeAndFindCategories:
            [self.delegate craigsListRepositorySetTypeAndFindCategoriesError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSetCategoryLoadInformationForm:
            [self.delegate craigsListRepositorySetCategoryAndLoadInformationFormError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSetPostInformationAndLoadImageForm:
            [self.delegate craigsListRepositorySetPostInformationAndLoadImageFormError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSetPostFinishedWithImages:
            [self.delegate craigsListRepositoryAddImageError:connection didFailWithError:error];
            break;
        case CraigsListRepositoryStateSubmitFinalPost:
            [self.delegate craigsListRepositorySubmitFinalPost:connection didFailWithError:error];
            break;
    }
}

#pragma mark - Parsing methods

/**
 * Parse the area html response
 */
- (void) parseAreaResponse:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositoryFindAreasError:connection didFailWithError:error];
        return;
    }
    
    self.areaFormAction = [[[node queryWithXPath:@"//form[@class='areapick picker']"] firstObject] attribute:@"action"];
    self.areaInputName = [[[node queryWithXPath:@"//form[@class='areapick picker']/select"] firstObject] attribute:@"name"];
    self.areaInputHiddenName = [[[node queryWithXPath:@"//form[@class='areapick picker']/input[@type='hidden']"] firstObject] attribute:@"name"];
    self.areaInputHiddenValue = [[[node queryWithXPath:@"//form[@class='areapick picker']/input[@type='hidden']"] firstObject] attribute:@"value"];
    
    [[node queryWithXPath:@"//form[@class='areapick picker']/select/option"] enumerateNodesUsingBlock:^(IGXMLNode *areaOption, NSUInteger idx, BOOL *stop) {
        [self.areas addObject:[[Area alloc] initWithValue:[areaOption attribute:@"value"] andName:areaOption.text]];
    }];
    
    NSLog(@"Area Response: %@", html);
    NSLog(@"self.areaFormAction: %@", _areaFormAction);
    NSLog(@"self.areaInputName: %@", _areaInputName);
    NSLog(@"self.areaInputHiddenName: %@", _areaInputHiddenName);
    NSLog(@"self.areaInputHiddenValue: %@", _areaInputHiddenValue);
    NSLog(@"self.areas: %@", _areas);
    
    [self.delegate craigsListRepositoryFindAreasFinished:connection];
    [self setAreaAndFindTypes];
}

/**
 * Parse the type html response
 */
- (void) parseTypeResponse:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositorySetAreaAndFindTypesError:connection didFailWithError:error];
        return;
    }
    
    self.typeFormAction = [[[node queryWithXPath:@"//form[@class='catpick picker']"] firstObject] attribute:@"action"];
    self.typeInputName = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='radio']"] firstObject] attribute:@"name"];
    self.typeInputHiddenName = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='hidden']"] firstObject] attribute:@"name"];
    self.typeInputHiddenValue = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='hidden']"] firstObject] attribute:@"value"];
    
    [[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='radio']"] enumerateNodesUsingBlock:^(IGXMLNode *typeOption, NSUInteger idx, BOOL *stop) {
        [self.types addObject:[[Type alloc] initWithValue:[typeOption attribute:@"value"] andName:[[typeOption parent] text]]];
    }];
    
    NSLog(@"Type Response: %@", html);
    NSLog(@"self.typeFormAction: %@", self.typeFormAction);
    NSLog(@"self.typeInputName: %@", self.typeInputName);
    NSLog(@"self.typeInputHiddenName: %@", self.typeInputHiddenName);
    NSLog(@"self.typeInputHiddenValue: %@", self.typeInputHiddenValue);
    NSLog(@"self.types: %@", self.types);
    
    [self.delegate craigsListRepositorySetAreaAndFindTypesFinished:connection];
    [self setTypeAndFindCategories];
}

/**
 * Parse the category html response
 */
- (void) parseCategoryResponse:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositorySetTypeAndFindCategoriesError: connection didFailWithError:error];
        return;
    }
    
    self.categoryFormAction = [[[node queryWithXPath:@"//form[@class='catpick picker']"] firstObject] attribute:@"action"];
    self.categoryInputName = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='radio']"] firstObject] attribute:@"name"];
    self.categoryInputHiddenName = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='hidden']"] firstObject] attribute:@"name"];
    self.categoryInputHiddenValue = [[[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='hidden']"] firstObject] attribute:@"value"];
    
    [[node queryWithXPath:@"//form[@class='catpick picker']//input[@type='radio']"] enumerateNodesUsingBlock:^(IGXMLNode *categoryOption, NSUInteger idx, BOOL *stop) {
        [self.categories addObject:[[Category alloc] initWithValue:[categoryOption attribute:@"value"] andName:[[categoryOption parent] text]]];
    }];
    
    NSLog(@"Category Response: %@", html);
    NSLog(@"self.categoryFormAction: %@", self.categoryFormAction);
    NSLog(@"self.categoryInputName: %@", self.categoryInputName);
    NSLog(@"self.categoryInputHiddenName: %@", self.categoryInputHiddenName);
    NSLog(@"self.categoryInputHiddenValue: %@", self.categoryInputHiddenValue);
    NSLog(@"self.categories: %@", self.categories);
    
    [self.delegate craigsListRepositorySetTypeAndFindCategoriesFinished:connection];
    [self setCategoryAndLoadInformationForm];
}

/**
 * Parse the post html response
 */
- (void) parsePostListingResponse:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositorySetCategoryAndLoadInformationFormError:connection didFailWithError:error];
        return;
    }
    
    self.informationPostFormAction = [[[node queryWithXPath:@"//form[@id='postingForm']"] firstObject] attribute:@"action"];
    self.informationPostInputHiddenName = [[[node queryWithXPath:@"//form[@id='postingForm']//input[@type='hidden']"] firstObject] attribute:@"name"];
    self.informationPostInputHiddenValue = [[[node queryWithXPath:@"//form[@id='postingForm']//input[@type='hidden']"] firstObject] attribute:@"value"];
    
    NSLog(@"Post Response: %@", html);
    NSLog(@"self.informationpostFormAction: %@", self.informationPostFormAction);
    NSLog(@"self.informationPostInputHiddenName: %@", self.informationPostInputHiddenName);
    NSLog(@"self.informationPostInputHiddenValue: %@", self.informationPostInputHiddenValue);
    
    
    if ([self.post.currentImages count] > 0) {
        [self.delegate craigsListRepositoryAddImageFinished:connection];
        [self addImage];
    } else {
        [self.delegate craigsListRepositoryAddImageFinished:connection];
        [self setWithImagesLoadFinalReview];
    }
}

- (void) parseImageForm:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositorySetPostInformationAndLoadImageFormError:connection didFailWithError:error];
        return;
    }
    
    self.imageFormAction = [[[node queryWithXPath:@"//form[@enctype='multipart/form-data']"] firstObject] attribute:@"action"];
    self.imageInputHiddenName = [[[node queryWithXPath:@"//form[@enctype='multipart/form-data']//input[@type='hidden']"] firstObject] attribute:@"name"];
    self.imageInputHiddenValue = [[[node queryWithXPath:@"//form[@enctype='multipart/form-data']//input[@type='hidden']"] firstObject] attribute:@"value"];
    
    IGXMLNodeSet *forms = [node queryWithXPath:@"//form"];
    if (forms.count > 0) {
        IGXMLNode *lastForm = forms[forms.count - 1];
        self.doneWithImageFormAction = [lastForm attribute:@"action"];
        self.doneWithImageInputHiddenName = [[[node queryWithXPath:@"//input[@type='hidden']"] firstObject] attribute:@"name"];
        self.doneWithImageInputHiddenValue = [[[node queryWithXPath:@"//input[@type='hidden']"] firstObject] attribute:@"value"];
    }
    
    NSLog(@"Post Response: %@", html);
    NSLog(@"self.imageFormAction: %@", self.imageFormAction);
    NSLog(@"self.imageInputHiddenName: %@", self.imageInputHiddenName);
    NSLog(@"self.imageInputHiddenValue: %@", self.imageInputHiddenValue);
    
    NSLog(@"doneWithImageFormAction: %@", self.doneWithImageFormAction);
    NSLog(@"doneWithImageInputHiddenName: %@", self.doneWithImageInputHiddenName);
    NSLog(@"doneWithImageInputHiddenValue: %@", self.doneWithImageInputHiddenValue);
    
    
    if ([self.post.currentImages count] > 0) {
        [self.delegate craigsListRepositoryAddImageFinished:connection];
        [self addImage];
    } else {
        [self.delegate craigsListRepositoryAddImageFinished:connection];
        [self setWithImagesLoadFinalReview];
    }
    
}

- (void) parseDoneWithImages:(NSURLConnection *)connection orHtml:(NSString *) html {
    NSError *error = nil;
    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:html error:&error];
    if (error) {
        [self.delegate craigsListRepositoryDoneWithImagesError: connection didFailWithError:error];
        return;
    }
    
    self.finishFormAction = [[[node queryWithXPath:@"//form"] firstObject] attribute:@"action"];
    self.finishInputHiddenName = [[[node queryWithXPath:@"//form//input[@type='hidden']"] firstObject] attribute:@"name"];
    self.finishInputHiddenValue = [[[node queryWithXPath:@"//form//input[@type='hidden']"] firstObject] attribute:@"value"];
    
    NSLog(@"Post Response: %@", html);
    NSLog(@"finishFormAction: %@", self.finishFormAction);
    NSLog(@"finishInputHiddenName: %@", self.finishInputHiddenName);
    NSLog(@"finishInputHiddenValue: %@", self.finishInputHiddenValue);
    
    [self.delegate craigsListRepositoryDoneWithImagesFinished:connection];
    //[self submitFinalPost];
}


- (void) parseSubmitFinalPost:(NSURLConnection *)connection orHtml:(NSString *) html {
    [self.delegate craigsListRepositorySubmitFinalPost:connection];
}


- (void) runTests {
    /*
     [self parseAreaResponse:nil orHtml:[self sampleAreaHtml]];
     [self parseTypeResponse:nil orHtml:[self sampleTypeHtml]];
     [self parseCategoryResponse:nil orHtml:[self sampleCategoryHtml]];
     [self parsePostListingResponse:nil orHtml:[self samplePostHtml]];
     [self parseImageForm:nil orHtml:[self sampleImageHtml]];
     [self parseDoneWithImages:nil orHtml:[self sampleReviewHtml]];
     */
}


- (NSString *) sampleAreaHtml {
    return @"<!DOCTYPE html><html><head><base href=\"https://post.craigslist.org\"><title>craigslist | choose location</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=7f439fd704b2b9c24345a268155d1f13\"><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\"></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=b5cfddd80f1abf346d80b96a8e9e12d1\"></script><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\"></script><![endif]--></head><body class=\"post\"><script type=\"text/javascript\"><!--var h=document.documentElement;h.className=h.className.replace('nojs', '');var pagetype;function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var fmt=C('cl_fmt');var b=document.body;pagetype=b.className.replace(' ', '');if (fmt){b.className +=\" \" + fmt;}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){b.className +=' w1024';}var mode=C('cl_img');if (mode && b.className.indexOf('map')==-1){b.className +=\" \" + mode;}--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&rp=/k/vvky7Mfv4hG7syrRVInhMw/U6X67\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&rp=%2Fk%2Fvvky7Mfv4hG7syrRVInhMw%2FU6X67\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://www.craigslist.org/\"><b>craigslist</b></a> >choose location<br></section><br clear=\"all\"></header><section class=\"body\"><form class=\"areapick picker\" action=\"https://post.craigslist.org/k/vvky7Mfv4hG7syrRVInhMw/U6X67\" method=\"POST\">which city / area would you like to post to?<br><br><em>note!</em> only post to one city at a time;identical posts to multiple cities / areas are against craigslist's terms of use<br><br><select name=\"U2FsdGVkX181MzM0NTM:zNCx8202zxYN6ziK3X4x6bQ7e77bJMEgwrn1PAWk-Kp-9\"><option value=\"318\">aberdeen<option value=\"364\">abilene<option value=\"512\">acapulco<option value=\"68\">adelaide<option value=\"450\">ahmedabad<option value=\"251\">akron / canton<option value=\"59\">albany<option value=\"637\">albany, GA<option value=\"50\">albuquerque<option value=\"533\">alicante<option value=\"355\">altoona-johnstown<option value=\"269\">amarillo<option value=\"445\">ames, IA<option value=\"82\">amsterdam / randstad<option value=\"51\">anchorage / mat-su<option value=\"172\">ann arbor<option value=\"460\">annapolis<option value=\"243\">appleton-oshkosh-FDL<option value=\"171\">asheville<option value=\"700\">ashtabula<option value=\"258\">athens, GA<option value=\"438\">athens, OH<option value=\"14\">atlanta<option value=\"372\">auburn<option value=\"69\">auckland, NZ<option value=\"256\">augusta<option value=\"15\">austin<option value=\"606\">bacolod<option value=\"406\">baja california sur<option value=\"63\">bakersfield<option value=\"534\">baleares<option value=\"34\">baltimore<option value=\"84\">bangalore<option value=\"295\">bangladesh<option value=\"83\">barcelona<option value=\"389\">barrie<option value=\"528\">basel<option value=\"494\">bath<option value=\"199\">baton rouge<option value=\"628\">battle creek<option value=\"264\">beaumont / port arthur<option value=\"154\">beijing<option value=\"296\">beirut, lebanon<option value=\"115\">belfast<option value=\"109\">belgium<option value=\"483\">belleville, ON<option value=\"217\">bellingham<option value=\"513\">belo horizonte<option value=\"663\">bemidji<option value=\"233\">bend<option value=\"108\">berlin<option value=\"529\">bern<option value=\"612\">bhubaneswar<option value=\"609\">bicol region<option value=\"535\">bilbao<option value=\"657\">billings<option value=\"248\">binghamton<option value=\"72\">birmingham / west mids<option value=\"127\">birmingham, AL<option value=\"666\">bismarck<option value=\"229\">bloomington, IN<option value=\"344\">bloomington-normal<option value=\"52\">boise<option value=\"578\">bolivia<option value=\"396\">bologna<option value=\"446\">boone<option value=\"412\">bordeaux<option value=\"4\">boston<option value=\"319\">boulder<option value=\"342\">bowling green<option value=\"658\">bozeman<option value=\"664\">brainerd<option value=\"626\">brantford-woodstock<option value=\"514\">brasilia<option value=\"522\">bremen<option value=\"398\">brighton<option value=\"66\">brisbane<option value=\"117\">bristol<option value=\"526\">brittany<option value=\"266\">brownsville<option value=\"570\">brunswick, GA<option value=\"153\">budapest<option value=\"114\">buenos aires<option value=\"40\">buffalo<option value=\"584\">bulgaria<option value=\"661\">butte<option value=\"536\">cadiz<option value=\"604\">cagayan de oro<option value=\"592\">cairns<option value=\"77\">calgary<option value=\"312\">cambridge, UK<option value=\"537\">canarias<option value=\"489\">canberra<option value=\"239\">cape cod / islands<option value=\"136\">cape town<option value=\"116\">cardiff / wales<option value=\"299\">caribbean islands<option value=\"621\">cariboo<option value=\"451\">catskills<option value=\"548\">cebu<option value=\"340\">cedar rapids<option value=\"644\">central louisiana<option value=\"434\">central michigan<option value=\"349\">central NJ<option value=\"190\">champaign urbana<option value=\"610\">chandigarh<option value=\"128\">charleston, SC<option value=\"439\">charleston, WV<option value=\"41\">charlotte<option value=\"290\">charlottesville<option value=\"484\">chatham-kent<option value=\"220\">chattanooga<option value=\"452\">chautauqua<option value=\"602\">chengdu<option value=\"182\">chennai (madras)<option value=\"11\">chicago<option value=\"187\">chico<option value=\"505\">chihuahua<option value=\"158\">chile<option value=\"701\">chillicothe<option value=\"601\">chongqing<option value=\"301\">christchurch<option value=\"35\">cincinnati, OH<option value=\"511\">ciudad juarez<option value=\"465\">clarksville, TN<option value=\"27\">cleveland<option value=\"653\">clovis / portales<option value=\"326\">college station<option value=\"313\">cologne<option value=\"393\">colombia<option value=\"210\">colorado springs<option value=\"222\">columbia / jeff city<option value=\"101\">columbia, SC<option value=\"42\">columbus<option value=\"343\">columbus, GA<option value=\"473\">comox valley<option value=\"670\">cookeville<option value=\"107\">copenhagen<option value=\"481\">cornwall, ON<option value=\"265\">corpus christi<option value=\"350\">corvallis/albany<option value=\"179\">costa rica<option value=\"495\">coventry<option value=\"546\">croatia<option value=\"705\">cumberland valley<option value=\"517\">curitiba<option value=\"600\">dalian<option value=\"21\">dallas / fort worth<option value=\"367\">danville<option value=\"491\">darwin<option value=\"547\">davao city<option value=\"131\">dayton / springfield<option value=\"238\">daytona beach<option value=\"569\">decatur, IL<option value=\"645\">deep east texas<option value=\"647\">del rio / eagle pass<option value=\"193\">delaware<option value=\"86\">delhi<option value=\"13\">denver<option value=\"496\">derby<option value=\"98\">des moines<option value=\"22\">detroit metro<option value=\"399\">devon &cornwall<option value=\"617\">dominican republic<option value=\"467\">dothan, AL<option value=\"521\">dresden<option value=\"74\">dublin<option value=\"362\">dubuque<option value=\"255\">duluth / superior<option value=\"498\">dundee<option value=\"594\">dunedin<option value=\"303\">durban<option value=\"418\">dusseldorf<option value=\"402\">east anglia<option value=\"424\">east idaho<option value=\"400\">east midlands<option value=\"322\">east oregon<option value=\"713\">eastern CO<option value=\"281\">eastern CT<option value=\"674\">eastern kentucky<option value=\"192\">eastern montana<option value=\"335\">eastern NC<option value=\"444\">eastern panhandle<option value=\"328\">eastern shore<option value=\"242\">eau claire<option value=\"545\">ecuador<option value=\"75\">edinburgh<option value=\"78\">edmonton<option value=\"162\">egypt<option value=\"132\">el paso<option value=\"587\">el salvador<option value=\"652\">elko<option value=\"453\">elmira-corning<option value=\"275\">erie, PA<option value=\"523\">essen / ruhr<option value=\"497\">essex<option value=\"576\">ethiopia<option value=\"94\">eugene<option value=\"227\">evansville<option value=\"677\">fairbanks<option value=\"435\">fargo / moorhead<option value=\"568\">farmington, NM<option value=\"542\">faro / algarve<option value=\"273\">fayetteville<option value=\"293\">fayetteville, AR<option value=\"685\">finger lakes<option value=\"145\">finland<option value=\"244\">flagstaff / sedona<option value=\"259\">flint<option value=\"560\">florence / muscle shoals<option value=\"152\">florence / tuscany<option value=\"464\">florence, SC<option value=\"330\">florida keys<option value=\"287\">fort collins / north CO<option value=\"693\">fort dodge<option value=\"358\">fort smith, AR<option value=\"226\">fort wayne<option value=\"518\">fortaleza<option value=\"141\">frankfurt<option value=\"471\">fraser valley<option value=\"633\">frederick<option value=\"457\">fredericksburg<option value=\"43\">fresno / madera<option value=\"477\">ft mcmurray<option value=\"125\">ft myers / SW florida<option value=\"503\">fukuoka<option value=\"559\">gadsden-anniston<option value=\"219\">gainesville<option value=\"470\">galveston<option value=\"146\">geneva<option value=\"531\">genoa<option value=\"575\">ghana<option value=\"73\">glasgow<option value=\"686\">glens falls<option value=\"430\">goa<option value=\"590\">gold coast<option value=\"373\">gold country<option value=\"538\">granada<option value=\"667\">grand forks<option value=\"432\">grand island<option value=\"129\">grand rapids<option value=\"660\">great falls<option value=\"144\">greece<option value=\"241\">green bay<option value=\"61\">greensboro<option value=\"253\">greenville / upstate<option value=\"525\">grenoble<option value=\"404\">guadalajara<option value=\"245\">guam-micronesia<option value=\"431\">guanajuato<option value=\"409\">guangzhou<option value=\"585\">guatemala<option value=\"482\">guelph<option value=\"230\">gulfport / biloxi<option value=\"391\">haifa<option value=\"174\">halifax<option value=\"140\">hamburg<option value=\"213\">hamilton-burlington<option value=\"403\">hampshire<option value=\"48\">hampton roads<option value=\"709\">hanford-corcoran<option value=\"500\">hangzhou<option value=\"417\">hannover<option value=\"166\">harrisburg<option value=\"447\">harrisonburg<option value=\"44\">hartford<option value=\"374\">hattiesburg<option value=\"28\">hawaii<option value=\"639\">heartland florida<option value=\"519\">heidelberg<option value=\"659\">helena<option value=\"506\">hermosillo<option value=\"462\">hickory / lenoir<option value=\"288\">high rockies<option value=\"353\">hilton head<option value=\"504\">hiroshima<option value=\"630\">holland<option value=\"87\">hong kong<option value=\"643\">houma<option value=\"23\">houston<option value=\"249\">hudson valley<option value=\"189\">humboldt county<option value=\"442\">huntington-ashland<option value=\"231\">huntsville / decatur<option value=\"183\">hyderabad<option value=\"605\">iloilo<option value=\"455\">imperial county<option value=\"45\">indianapolis<option value=\"157\">indonesia<option value=\"549\">indore<option value=\"104\">inland empire<option value=\"339\">iowa city<option value=\"589\">iran<option value=\"588\">iraq<option value=\"201\">ithaca<option value=\"426\">jackson, MI<option value=\"134\">jackson, MS<option value=\"558\">jackson, TN<option value=\"80\">jacksonville<option value=\"634\">jacksonville, NC<option value=\"550\">jaipur<option value=\"553\">janesville<option value=\"561\">jersey shore<option value=\"161\">jerusalem<option value=\"185\">johannesburg<option value=\"425\">jonesboro<option value=\"423\">joplin<option value=\"618\">kaiserslautern<option value=\"261\">kalamazoo<option value=\"662\">kalispell<option value=\"381\">kamloops<option value=\"30\">kansas city, MO<option value=\"380\">kelowna / okanagan<option value=\"678\">kenai peninsula<option value=\"324\">kennewick-pasco-richland<option value=\"552\">kenosha-racine<option value=\"493\">kent<option value=\"582\">kenya<option value=\"410\">kerala<option value=\"327\">killeen / temple / ft hood<option value=\"385\">kingston, ON<option value=\"696\">kirksville<option value=\"214\">kitchener-waterloo-cambridge<option value=\"675\">klamath falls<option value=\"202\">knoxville<option value=\"672\">kokomo<option value=\"184\">kolkata (calcutta)<option value=\"474\">kootenays<option value=\"577\">kuwait<option value=\"363\">la crosse<option value=\"698\">la salle co<option value=\"283\">lafayette<option value=\"360\">lafayette / west lafayette<option value=\"284\">lake charles<option value=\"695\">lake of the ozarks<option value=\"376\">lakeland<option value=\"279\">lancaster, PA<option value=\"212\">lansing<option value=\"271\">laredo<option value=\"334\">las cruces<option value=\"26\">las vegas<option value=\"615\">lausanne<option value=\"347\">lawrence<option value=\"422\">lawton<option value=\"123\">leeds<option value=\"167\">lehigh valley<option value=\"520\">leipzig<option value=\"476\">lethbridge<option value=\"654\">lewiston / clarkston<option value=\"133\">lexington, KY<option value=\"413\">lille<option value=\"437\">lima / findlay<option value=\"282\">lincoln<option value=\"540\">lisbon<option value=\"100\">little rock<option value=\"118\">liverpool<option value=\"448\">logan<option value=\"415\">loire valley<option value=\"24\">london<option value=\"234\">london, ON<option value=\"250\">long island<option value=\"7\">los angeles<option value=\"58\">louisville<option value=\"267\">lubbock<option value=\"611\">lucknow<option value=\"544\">luxembourg<option value=\"366\">lynchburg<option value=\"150\">lyon<option value=\"257\">macon / warner robins<option value=\"165\">madison<option value=\"110\">madrid<option value=\"169\">maine<option value=\"539\">malaga<option value=\"297\">malaysia<option value=\"71\">manchester<option value=\"428\">manhattan, KS<option value=\"90\">manila<option value=\"421\">mankato<option value=\"436\">mansfield<option value=\"149\">marseille<option value=\"692\">mason city<option value=\"699\">mattoon-charleston<option value=\"509\">mazatlan<option value=\"263\">mcallen / edinburg<option value=\"706\">meadville<option value=\"216\">medford-ashland<option value=\"619\">medicine hat<option value=\"65\">melbourne<option value=\"46\">memphis, TN<option value=\"454\">mendocino county<option value=\"285\">merced<option value=\"641\">meridian<option value=\"91\">mexico city<option value=\"111\">milan<option value=\"47\">milwaukee<option value=\"19\">minneapolis / st paul<option value=\"656\">missoula<option value=\"200\">mobile<option value=\"96\">modesto<option value=\"565\">mohave county<option value=\"629\">monroe<option value=\"563\">monroe, LA<option value=\"102\">monterey bay<option value=\"408\">monterrey<option value=\"543\">montevideo<option value=\"207\">montgomery<option value=\"524\">montpellier<option value=\"49\">montreal<option value=\"440\">morgantown<option value=\"580\">morocco<option value=\"137\">moscow<option value=\"655\">moses lake<option value=\"85\">mumbai<option value=\"361\">muncie / anderson<option value=\"142\">munich<option value=\"554\">muskegon<option value=\"254\">myrtle beach<option value=\"501\">nagoya<option value=\"382\">nanaimo<option value=\"599\">nanjing<option value=\"151\">napoli / campania<option value=\"32\">nashville<option value=\"379\">new brunswick<option value=\"198\">new hampshire<option value=\"168\">new haven<option value=\"31\">new orleans<option value=\"291\">new river valley<option value=\"3\">new york city<option value=\"163\">newcastle / NE england<option value=\"591\">newcastle, NSW<option value=\"386\">niagara region<option value=\"586\">nicaragua<option value=\"306\">nice / cote d'azur<option value=\"527\">normandy<option value=\"638\">north central FL<option value=\"196\">north dakota<option value=\"170\">north jersey<option value=\"375\">north mississippi<option value=\"668\">north platte<option value=\"682\">northeast SD<option value=\"309\">northern michigan<option value=\"443\">northern panhandle<option value=\"631\">northern WI<option value=\"354\">northwest CT<option value=\"636\">northwest GA<option value=\"688\">northwest KS<option value=\"650\">northwest OK<option value=\"105\">norway<option value=\"492\">nottingham<option value=\"614\">nuremberg<option value=\"510\">oaxaca<option value=\"333\">ocala<option value=\"268\">odessa / midland<option value=\"351\">ogden-clearfield<option value=\"640\">okaloosa / walton<option value=\"429\">okinawa<option value=\"54\">oklahoma city<option value=\"466\">olympic peninsula<option value=\"55\">omaha / council bluffs<option value=\"684\">oneonta<option value=\"103\">orange county<option value=\"321\">oregon coast<option value=\"39\">orlando<option value=\"120\">osaka-kobe-kyoto<option value=\"76\">ottawa-hull-gatineau<option value=\"336\">outer banks<option value=\"487\">owen sound<option value=\"673\">owensboro<option value=\"211\">oxford<option value=\"294\">pakistan<option value=\"209\">palm springs, CA<option value=\"608\">pampanga<option value=\"298\">panama<option value=\"562\">panama city, FL<option value=\"81\">paris<option value=\"441\">parkersburg-marietta<option value=\"620\">peace river country<option value=\"203\">pensacola<option value=\"224\">peoria<option value=\"67\">perth<option value=\"159\">peru<option value=\"530\">perugia<option value=\"388\">peterborough<option value=\"17\">philadelphia<option value=\"18\">phoenix<option value=\"681\">pierre / central SD<option value=\"33\">pittsburgh<option value=\"338\">plattsburgh-adirondacks<option value=\"356\">poconos<option value=\"147\">poland<option value=\"555\">port huron<option value=\"9\">portland, OR<option value=\"541\">porto<option value=\"515\">porto alegre<option value=\"683\">potsdam-canton-massena<option value=\"138\">prague<option value=\"419\">prescott<option value=\"595\">pretoria<option value=\"304\">prince edward island<option value=\"383\">prince george<option value=\"292\">provo / orem<option value=\"508\">puebla<option value=\"315\">pueblo<option value=\"180\">puerto rico<option value=\"407\">puerto vallarta<option value=\"368\">pullman / moscow<option value=\"317\">pune<option value=\"307\">quad cities, IA/IL<option value=\"175\">quebec city<option value=\"36\">raleigh / durham / CH<option value=\"680\">rapid city / west SD<option value=\"278\">reading<option value=\"516\">recife<option value=\"475\">red deer<option value=\"188\">redding<option value=\"478\">regina<option value=\"92\">reno / tahoe<option value=\"579\">reykjavik<option value=\"38\">rhode island<option value=\"60\">richmond<option value=\"671\">richmond, IN<option value=\"139\">rio de janeiro<option value=\"289\">roanoke<option value=\"316\">rochester, MN<option value=\"126\">rochester, NY<option value=\"223\">rockford<option value=\"574\">romania<option value=\"121\">rome<option value=\"459\">roseburg<option value=\"420\">roswell / carlsbad<option value=\"12\">sacramento<option value=\"260\">saginaw-midland-baycity<option value=\"480\">saguenay<option value=\"232\">salem, OR<option value=\"690\">salina<option value=\"56\">salt lake city<option value=\"392\">salvador, bahia<option value=\"646\">san angelo<option value=\"53\">san antonio<option value=\"8\">san diego<option value=\"191\">san luis obispo<option value=\"449\">san marcos<option value=\"573\">sandusky<option value=\"62\">santa barbara<option value=\"218\">santa fe / taos<option value=\"710\">santa maria<option value=\"113\">sao paulo<option value=\"502\">sapporo<option value=\"237\">sarasota-bradenton<option value=\"532\">sardinia<option value=\"486\">sarnia<option value=\"176\">saskatoon<option value=\"485\">sault ste marie, ON<option value=\"205\">savannah / hinesville<option value=\"669\">scottsbluff / panhandle<option value=\"276\">scranton / wilkes-barre<option value=\"2\">seattle-tacoma<option value=\"596\">sendai<option value=\"119\">seoul<option value=\"395\">sevilla<option value=\"1\" selected>SF bay area<option value=\"135\">shanghai<option value=\"571\">sheboygan, WI<option value=\"401\">sheffield<option value=\"598\">shenyang<option value=\"499\">shenzhen<option value=\"390\">sherbrooke<option value=\"651\">show low<option value=\"206\">shreveport<option value=\"311\">sicilia<option value=\"468\">sierra vista<option value=\"89\">singapore<option value=\"341\">sioux city, IA<option value=\"679\">sioux falls / SE SD<option value=\"708\">siskiyou county<option value=\"461\">skagit / island / SJI<option value=\"623\">skeena-bulkley<option value=\"228\">south bend / michiana<option value=\"378\">south coast<option value=\"195\">south dakota<option value=\"20\">south florida<option value=\"286\">south jersey<option value=\"676\">southeast alaska<option value=\"691\">southeast IA<option value=\"689\">southeast KS<option value=\"566\">southeast missouri<option value=\"345\">southern illinois<option value=\"556\">southern maryland<option value=\"632\">southern WV<option value=\"687\">southwest KS<option value=\"572\">southwest michigan<option value=\"665\">southwest MN<option value=\"642\">southwest MS<option value=\"648\">southwest TX<option value=\"712\">southwest VA<option value=\"331\">space coast<option value=\"95\">spokane / coeur d'alene<option value=\"225\">springfield, IL<option value=\"221\">springfield, MO<option value=\"557\">st augustine<option value=\"369\">st cloud<option value=\"352\">st george<option value=\"305\">st john's, NL<option value=\"694\">st joseph<option value=\"29\">st louis, MO<option value=\"143\">st petersburg, RU<option value=\"277\">state college<option value=\"635\">statesboro<option value=\"433\">stillwater<option value=\"97\">stockton<option value=\"414\">strasbourg<option value=\"416\">stuttgart<option value=\"384\">sudbury<option value=\"622\">sunshine coast<option value=\"613\">surat surat<option value=\"707\">susanville<option value=\"106\">sweden<option value=\"64\">sydney<option value=\"130\">syracuse<option value=\"155\">taiwan<option value=\"186\">tallahassee<option value=\"37\">tampa bay area<option value=\"490\">tasmania<option value=\"160\">tel aviv<option value=\"348\">terre haute<option value=\"488\">territories<option value=\"359\">texarkana<option value=\"649\">texoma<option value=\"156\">thailand<option value=\"627\">the thumb<option value=\"387\">thunder bay<option value=\"181\">tijuana<option value=\"88\">tokyo<option value=\"204\">toledo<option value=\"280\">topeka<option value=\"397\">torino<option value=\"25\">toronto<option value=\"411\">toulouse<option value=\"332\">treasure coast<option value=\"323\">tri-cities, TN<option value=\"479\">trois-rivieres<option value=\"57\">tucson<option value=\"70\">tulsa<option value=\"581\">tunisia<option value=\"148\">turkey<option value=\"371\">tuscaloosa<option value=\"703\">tuscarawas co<option value=\"469\">twin falls<option value=\"704\">twin tiers NY/PA<option value=\"308\">tyler / east TX<option value=\"583\">ukraine<option value=\"215\">united arab emirates<option value=\"262\">upper peninsula<option value=\"247\">utica-rome-oneida<option value=\"427\">valdosta<option value=\"394\">valencia<option value=\"16\">vancouver, BC<option value=\"178\">venezuela<option value=\"310\">venice / veneto<option value=\"208\">ventura county<option value=\"507\">veracruz<option value=\"93\">vermont<option value=\"177\">victoria<option value=\"564\">victoria, TX<option value=\"122\">vienna<option value=\"314\">vietnam<option value=\"616\">virgin islands<option value=\"346\">visalia-tulare<option value=\"270\">waco<option value=\"10\">washington, DC<option value=\"567\">waterloo / cedar falls<option value=\"337\">watertown<option value=\"458\">wausau<option value=\"302\">wellington<option value=\"325\">wenatchee<option value=\"551\">west bank<option value=\"194\">west virginia (old)<option value=\"697\">western IL<option value=\"377\">western KY<option value=\"329\">western maryland<option value=\"173\">western massachusetts<option value=\"320\">western slope<option value=\"472\">whistler, BC<option value=\"625\">whitehorse<option value=\"99\">wichita<option value=\"365\">wichita falls<option value=\"463\">williamsport<option value=\"274\">wilmington, NC<option value=\"711\">winchester<option value=\"235\">windsor<option value=\"79\">winnipeg<option value=\"272\">winston-salem<option value=\"593\">wollongong<option value=\"240\">worcester / central MA<option value=\"597\">wuhan<option value=\"197\">wyoming<option value=\"603\">xi'an<option value=\"246\">yakima<option value=\"624\">yellowknife<option value=\"357\">york, PA<option value=\"252\">youngstown<option value=\"456\">yuba-sutter<option value=\"405\">yucatan<option value=\"370\">yuma<option value=\"607\">zamboanga<option value=\"702\">zanesville / cambridge<option value=\"112\">zurich</select><input type=\"hidden\" name=\"U2FsdGVkX181MzM0NTMzN.CZejw6KtsZrox8oGsWdGvdmc8aTND.ZDvRhP7ArC_9vyij9YwaALu7xLQPUMrd:.Lw3A\" value=\"U2FsdGVkX181MzM0NTMzNArDb5Bywtmm62sysEa6fENiC7_WgzRC83OsxICrHDfn\"><br><br><button type=\"submit\" class=\"pickbutton\" name=\"go\" value=\"Continue\">continue</button></form></section>";
}

- (NSString *) sampleTypeHtml {
    return @"<!DOCTYPE html><html><head><base href=\"https://post.craigslist.org\"><title>athens, GA craigslist | choose type</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=7f439fd704b2b9c24345a268155d1f13\"><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\"></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=b5cfddd80f1abf346d80b96a8e9e12d1\"></script><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\"></script><![endif]--></head><body class=\"post\"><script type=\"text/javascript\"><!--var h=document.documentElement;h.className=h.className.replace('nojs', '');var pagetype;function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var fmt=C('cl_fmt');var b=document.body;pagetype=b.className.replace(' ', '');if (fmt){b.className +=\" \" + fmt;}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){b.className +=' w1024';}var mode=C('cl_img');if (mode && b.className.indexOf('map')==-1){b.className +=\" \" + mode;}--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&rp=/k/vvky7Mfv4hG7syrRVInhMw/U6X67\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&rp=%2Fk%2Fvvky7Mfv4hG7syrRVInhMw%2FU6X67\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://athensga.craigslist.org/\"><b>athens, GA craigslist</b></a> >choose type<br></section><br clear=\"all\"></header><section class=\"body\"><div class=\"highlight\"><i>please limit each posting to a single area and category, once per 48 hours, <a href=\"http://www.craigslist.org/about/prohibited.items\">no prohibited items</a>.</i></div><p class=\"formnote\"><b>what type of posting is this:</b></p><form class=\"catpick picker\" action=\"https://post.craigslist.org/k/vvky7Mfv4hG7syrRVInhMw/U6X67\" method=\"POST\"><blockquote><label><input type=\"radio\" name=\"id\" value=\"jo\" onclick=\"form.submit();return false;\">job offered </label><br><label><input type=\"radio\" name=\"id\" value=\"go\" onclick=\"form.submit();return false;\">gig offered</label><i>(I'm hiring for a short-term, small or odd job)</i><br><label><input type=\"radio\" name=\"id\" value=\"jw\" onclick=\"form.submit();return false;\">resume / job wanted</label><br><br><label><input type=\"radio\" name=\"id\" value=\"ho\" onclick=\"form.submit();return false;\">housing offered</label><br><label><input type=\"radio\" name=\"id\" value=\"hw\" onclick=\"form.submit();return false;\">housing wanted</label><br><br><label><input type=\"radio\" name=\"id\" value=\"fso\" onclick=\"form.submit();return false;\">for sale by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"fsd\" onclick=\"form.submit();return false;\">for sale by dealer</label><br><label><input type=\"radio\" name=\"id\" value=\"iw\" onclick=\"form.submit();return false;\">item wanted</label><br><br><label><input type=\"radio\" name=\"id\" value=\"so\" onclick=\"form.submit();return false;\">service offered</label><br><br><label><input type=\"radio\" name=\"id\" value=\"p\" onclick=\"form.submit();return false;\">personal / romance</label><br><br><label><input type=\"radio\" name=\"id\" value=\"c\" onclick=\"form.submit();return false;\">community</label><br><label><input type=\"radio\" name=\"id\" value=\"e\" onclick=\"form.submit();return false;\">event</label><br><br></blockquote><input type=\"hidden\" name=\"U2FsdGVkX181Mzc5NTM3ObD9DfPw_x42wNzHHMx3qVgQYdZQGqWb-QyjwcsehzFkvbYyS7_7RpFi2ScOiX-jFA\" value=\"U2FsdGVkX181Mzc5NTM3OfUPAQ4WcHQcmQV8DaptSYzQ7l9RFEv67UsJ5neTM8ui\"><button type=\"submit\" class=\"pickbutton\" name=\"go\" value=\"Continue\">continue</button></form></section>";
}

- (NSString *) sampleCategoryHtml {
    return @"<!DOCTYPE html><html><head><base href=\"https://post.craigslist.org\"><title>athens, GA craigslist | choose category</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=7f439fd704b2b9c24345a268155d1f13\"><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\"></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=b5cfddd80f1abf346d80b96a8e9e12d1\"></script><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\"></script><![endif]--></head><body class=\"post\"><script type=\"text/javascript\"><!--var h=document.documentElement;h.className=h.className.replace('nojs', '');var pagetype;function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var fmt=C('cl_fmt');var b=document.body;pagetype=b.className.replace(' ', '');if (fmt){b.className +=\" \" + fmt;}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){b.className +=' w1024';}var mode=C('cl_img');if (mode && b.className.indexOf('map')==-1){b.className +=\" \" + mode;}--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&rp=/k/vvky7Mfv4hG7syrRVInhMw/U6X67\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&rp=%2Fk%2Fvvky7Mfv4hG7syrRVInhMw%2FU6X67\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://athensga.craigslist.org/\"><b>athens, GA craigslist</b></a> >for sale / wanted >choose category<br></section><br clear=\"all\"></header><section class=\"body\"><div class=\"highlight\"><b>AVOID SCAMS BY DEALING LOCALLY -- IGNORE DISTANT BUYERS (SCAMMERS):</b><br><ol><li>Most cashier's check or money orders offered to craigslist sellers are COUNTERFEIT -- cashing them can lead to financial ruin<li>Requests that you wire money abroad via Western Union or moneygram for any reason are SCAMS<br><li><a href=\"http://www.craigslist.org/about/scams\">Learn more on our scams page</a> -- avoid scammers by dealing locally with buyers you can meet in person!</ol></div><br><b class=\"formnote\">please choose a category:</b><form action=\"https://post.craigslist.org/k/vvky7Mfv4hG7syrRVInhMw/U6X67\" method=\"POST\" class=\"catpick picker\"><blockquote><label><input type=\"radio\" name=\"id\" value=\"150\" onclick=\"form.submit();return false;\">antiques - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"149\" onclick=\"form.submit();return false;\">appliances - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"135\" onclick=\"form.submit();return false;\">arts &crafts - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"122\" onclick=\"form.submit();return false;\">auto parts - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"107\" onclick=\"form.submit();return false;\">baby &kid stuff - by owner</label><i><span class=\"parenthetical\"> (no illegal sales of banned cribs, e.g. drop-side cribs)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"42\" onclick=\"form.submit();return false;\">barter</label><br><label><input type=\"radio\" name=\"id\" value=\"68\" onclick=\"form.submit();return false;\">bicycles - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"119\" onclick=\"form.submit();return false;\">boats - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"92\" onclick=\"form.submit();return false;\">books &magazines - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"134\" onclick=\"form.submit();return false;\">business/commercial - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"145\" onclick=\"form.submit();return false;\">cars &trucks - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"117\" onclick=\"form.submit();return false;\">cds / dvds / vhs - by owner</label><i><span class=\"parenthetical\"> (no pornography please)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"153\" onclick=\"form.submit();return false;\">cell phones - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"94\" onclick=\"form.submit();return false;\">clothing &accessories - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"95\" onclick=\"form.submit();return false;\">collectibles - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"7\" onclick=\"form.submit();return false;\">computers - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"96\" onclick=\"form.submit();return false;\">electronics - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"133\" onclick=\"form.submit();return false;\">farm &garden - by owner</label><i><span class=\"parenthetical\"> (legal sales of agricultural livestock OK)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"101\" onclick=\"form.submit();return false;\">free stuff</label><i><span class=\"parenthetical\"> (no \"wanted\" ads, pets, promotional giveaways, or intangible/digital items please)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"141\" onclick=\"form.submit();return false;\">furniture - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"73\" onclick=\"form.submit();return false;\">garage &moving sales</label><i><span class=\"parenthetical\"> (no online or virtual sales here please)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"5\" onclick=\"form.submit();return false;\">general for sale - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"152\" onclick=\"form.submit();return false;\">health and beauty - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"97\" onclick=\"form.submit();return false;\">household items - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"20\" onclick=\"form.submit();return false;\">items wanted</label><br><label><input type=\"radio\" name=\"id\" value=\"120\" onclick=\"form.submit();return false;\">jewelry - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"136\" onclick=\"form.submit();return false;\">materials - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"69\" onclick=\"form.submit();return false;\">motorcycles/scooters - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"98\" onclick=\"form.submit();return false;\">musical instruments - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"137\" onclick=\"form.submit();return false;\">photo/video - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"124\" onclick=\"form.submit();return false;\">rvs - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"93\" onclick=\"form.submit();return false;\">sporting goods - by owner</label><i><span class=\"parenthetical\"> (no firearms, ammunition, pellet/BB guns, stun guns, etc)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"44\" onclick=\"form.submit();return false;\">tickets - by owner</label><i><span class=\"parenthetical\"> (please do not sell tickets for more than face value)</span></i><br><label><input type=\"radio\" name=\"id\" value=\"118\" onclick=\"form.submit();return false;\">tools - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"132\" onclick=\"form.submit();return false;\">toys &games - by owner</label><br><label><input type=\"radio\" name=\"id\" value=\"151\" onclick=\"form.submit();return false;\">video gaming - by owner</label><br></blockquote><input type=\"hidden\" name=\"U.2FsdGVkX181NDAx:NTQwMYCDyoAGUAH50oI.Rd4LobBtzQ63Vq39tIwTnmjsnAG180QGTP0zGwWDVeLAvWYMWvg\" value=\"U2FsdGVkX181NDAxNTQwMQ_kptoSXVaqX7k-fJWQUEeEJ5Ap6wpl9mp_4danHOmu\"><button type=\"submit\" class=\"pickbutton\" name=\"go\" value=\"Continue\">continue</button></form></section>";
}

- (NSString *) samplePostHtml {
    return  @"<!DOCTYPE html><html class=\"nojs\"><head><base href=\"https://post.craigslist.org\"><title>athens, GA craigslist | create posting</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=ea10f746e3f02f1250ccc168f08223fc\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/jquery-ui-1.9.2.custom.css?v=cb67f2e720fe8a2c7d83234590b2d1ed\"><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\" ></script><![endif]--><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet-stock.css?v=3253c5512da7fc3c3c1dd35eae4ccf96\"><!--[if lte IE 8]><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet.ie.css?v=90b6a78525e3625dd48b1917cf28076f\"><![endif]--><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-ui-1.9.2.custom.js?v=32c38510c8db71f2fbef00da891aeaac\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery.timeago.js?v=85680edbac82b3e4f89d919796777ec4\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=5073b3dc61c933687ba35b2a7b84506e\" ></script><script type=\"text/javascript\"><!--var areaAbb=\"ahn\";--></script><script type=\"text/javascript\"><!--var lsDomain=\"www\";--></script></head><body class=\"post\"><script type=\"text/javascript\"><!--function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var pagetype, pagemode;(function(){var h=document.documentElement;h.className=h.className.replace('nojs', '');var b=document.body;var bodyClassList=b.className.split(/\\s+/);;pagetype=bodyClassList[0];var fmt=C('cl_fmt');if (fmt){pagemode=fmt;bodyClassList.push(fmt);}else if (screen.width <=480){pagemode='mobile';bodyClassList.push(pagemode);}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){bodyClassList.push('w1024');}if (typeof catType !=='undefined'){var mode=(decodeURIComponent(C('cl_img') || '').match(new RegExp(catType + ':([^,]+)', 'i')) ||{})[1];for (var i=0, len=bodyClassList.length;i < len;i++){if (bodyClassList[i]==='map'){mode=undefined;}}if (mode){bodyClassList.push(mode);}}b.className=bodyClassList.join(' ');}());--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&amp;rp=/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&amp;rp=%2Fk%2FMMLXnfx04xGKTm7mNMTI0w%2Fk8tWJ\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://athensga.craigslist.org/\"><b>athens, GA craigslist</b></a> &gt;for sale / wanted &gt;furniture - by owner &gt;create posting<br></section><br clear=\"all\"></header><section class=\"body\"><form id=\"postingForm\" action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><div class=\"posting shadow\"><fieldset style=\"margin-bottom: 1.5em;\"><legend>contact info</legend><div class=\"row fields\" style=\"margin-bottom: 0;\"><label class=\"std\"><div class=\"label\">preferred contact method</div><select tabindex=\"1\" name=\"contact_method\" id=\"contact_method\"><option value=\"0\" selected=\"selected\">-</option><option value=\"1\">email only</option><option value=\"2\">phone only</option><option value=\"3\">text only</option><option value=\"4\">email or phone</option><option value=\"5\">email or text</option><option value=\"6\">text or phone</option><option value=\"7\">phone, text, or email</option></select></label><label class=\"\"><div class=\"label\">phone</div><input type=\"text\" value=\"\" name=\"contact_phone\" id=\"contact_phone\" size=\"10\" maxlength=\"16\" tabindex=\"1\"></label><label class=\"\"><div class=\"label\">contact name</div><input type=\"text\" value=\"\" name=\"contact_name\" id=\"contact_name\" size=\"16\" maxlength=\"32\" tabindex=\"1\"></label></div><div class=\"row fields\" style=\"margin-bottom: 0;\"><span><label class=\"req\" for=\"FromEMail\"><div class=\"label\">email</div></label><input tabindex=\"1\" type=\"text\" class=\"req df\" id=\"FromEMail\" name=\"FromEMail\" value=\"Your email address\" maxlength=\"60\" autocapitalize=\"off\"><input tabindex=\"1\" type=\"text\" class=\"req df\" id=\"ConfirmEMail\" name=\"ConfirmEMail\" value=\"Type email address again\" maxlength=\"60\" autocapitalize=\"off\"></span><span id=\"oiab\"><label title=\"craigslist will anonymize your email address\"><input type=\"radio\" name=\"Privacy\" value=\"C\" checked tabindex=\"1\"> CL mail relay <small>(recommended)</small><sup>[<a title=\"how does mail relay work?\" target=\"_blank\" href=\"http://www.craigslist.org/about/help/email-relay\">?</a>]</sup></label><label title=\"no email address will appear in your posting - be sure to include other contact info!\"><input type=\"radio\" name=\"Privacy\" value=\"A\" id=\"A\" tabindex=\"1\"> no replies to this email</label></span></div></fieldset><br><div class=\"title row fields\"><label class=\"req\"><div class=\"label\">posting title</div><input class=\"req\" tabindex=\"1\" type=\"text\" name=\"PostingTitle\" id=\"PostingTitle\" maxlength=\"70\" value=\"\"></label><label class=\"std\"><div class=\"label\">price</div>&#x0024;<input type=\"text\" class=\"std\" tabindex=\"1\" size=\"4\" maxlength=\"7\" name=\"Ask\" id=\"Ask\" value=\"\"></label><label class=\"std\"><div class=\"label\">specific location</div><input type=\"text\" class=\"std\" data-suggest=\"geo\" tabindex=\"1\" name=\"GeographicArea\" id=\"GeographicArea\" size=\"20\" maxlength=\"40\" value=\"\"></label><label><div class=\"label\">postal code</div><input tabindex=\"1\" id='postal_code' class=\"std\" name=\"postal\" size=\"6\" maxlength=\"15\" value=\"\"></label></div><div class=\"row fields\"><label class=\"PostingBody req\"><div><span class=\"highlight\"> please enter phone numbers as contact info above, not in posting body below.</span><span class=\"label\">posting body</span></div><textarea class=\"req\" tabindex=\"1\" rows=\"10\" id=\"PostingBody\" name=\"PostingBody\"></textarea></label></div><div class=\"row\"></div><div class=\"row fields\"><fieldset><legend>posting details</legend><br><label class=\"std\"><input tabindex=\"1\" type=\"checkbox\" name=\"see_my_other\" id=\"see_my_other\" value=\"1\" >include \"more ads by this user\" link</label></fieldset></div><div class=\"row\"></div><div class=\"row disabled fields\" id=\"mapinfo\"><fieldset><legend><label><input data-checked=\"\" tabindex=\"1\" type=\"checkbox\" name=\"wantamap\" id=\"wantamap\"> show on maps </label><sup>[<a target='_blank' href=\"//www.craigslist.org/about/help/show_on_maps\">?</a>]</sup></legend><div class=\"street0\"><label class=\"std\"><small class=\"fieldnote\">optional</small><div class=\"label\">street</div><input tabindex=\"1\" id='xstreet0' class=\"nreq\" name=\"xstreet0\" size=\"20\" maxlength=\"80\" value=\"\"></label></div><div class=\"street1\"><label><small class=\"fieldnote\">optional</small><div class=\"label\">cross street</div><input tabindex=\"1\" id='xstreet1' class=\"nreq\" name=\"xstreet1\" size=\"20\" maxlength=\"80\" value=\"\"></label></div><div class=\"citystate\"><label class=\"std\"><div class=\"label\">city</div><input tabindex=\"1\" id='city' class=\"nreq\" name=\"city\" size=\"20\" maxlength=\"80\" value=\"\"><strong>,</strong></label><label><input tabindex=\"1\" id='region' class=\"nreq\" name=\"region\" size=\"2\" maxlength=\"2\" value=\"\"></label></div><div class=\"postal\"><label><div class=\"label\">postal code</div><input tabindex=\"1\" id='postal_code' class=\"nreq\" name=\"postal\" size=\"10\" maxlength=\"15\" value=\"\"></label></div></fieldset></div><div class=\"row\" id=\"perms\"><label for=\"oc\"><input tabindex=\"1\" type=\"checkbox\" id=\"oc\" name=\"outsideContactOK\" >ok for others to contact you about other services, products or commercial interests </label></div></div><button tabindex=\"1\" class=\"bigbutton\" type=\"submit\" name=\"go\" value=\"Continue\">continue</button><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX182MjQ2MjQ2MnVBWUEszjiMvoyVw9Z_ir03ziuHLBqlQvnYWv_hbzY_\"></form></section><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery.form-defaults.js?v=421648d06bad2f29bbfc2f66c5205aeb\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/json2.js?v=c1da07f5953739dffc17fd1db3c5313c\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/compatibility.js?v=02c7056c9b1ac2c371ff3b42559671c8\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/postingForm.js?v=d973eb54bdd0f831f53bb88946381fff\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/suggestions.js?v=3402c47237951f68650469f3b15ad2c4\" ></script></article></body></html>";
}

- (NSString *) sampleImageHtml {
    return @"<!DOCTYPE html><html class=\"nojs\"><head><base href=\"https://post.craigslist.org\"><title>athens, GA craigslist | create posting</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=ea10f746e3f02f1250ccc168f08223fc\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/jquery-ui-1.9.2.custom.css?v=cb67f2e720fe8a2c7d83234590b2d1ed\"><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\" ></script><![endif]--><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet-stock.css?v=3253c5512da7fc3c3c1dd35eae4ccf96\"><!--[if lte IE 8]><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet.ie.css?v=90b6a78525e3625dd48b1917cf28076f\"><![endif]--><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-ui-1.9.2.custom.js?v=32c38510c8db71f2fbef00da891aeaac\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery.timeago.js?v=85680edbac82b3e4f89d919796777ec4\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=5073b3dc61c933687ba35b2a7b84506e\" ></script><script type=\"text/javascript\"><!--var areaAbb=\"ahn\";--></script><script type=\"text/javascript\"><!--var lsDomain=\"www\";--></script></head><body class=\"post\"><script type=\"text/javascript\"><!--function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var pagetype, pagemode;(function(){var h=document.documentElement;h.className=h.className.replace('nojs', '');var b=document.body;var bodyClassList=b.className.split(/\\s+/);;pagetype=bodyClassList[0];var fmt=C('cl_fmt');if (fmt){pagemode=fmt;bodyClassList.push(fmt);}else if (screen.width <=480){pagemode='mobile';bodyClassList.push(pagemode);}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){bodyClassList.push('w1024');}if (typeof catType !=='undefined'){var mode=(decodeURIComponent(C('cl_img') || '').match(new RegExp(catType + ':([^,]+)', 'i')) ||{})[1];for (var i=0, len=bodyClassList.length;i < len;i++){if (bodyClassList[i]==='map'){mode=undefined;}}if (mode){bodyClassList.push(mode);}}b.className=bodyClassList.join(' ');}());--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&amp;rp=/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&amp;rp=%2Fk%2FMMLXnfx04xGKTm7mNMTI0w%2Fk8tWJ\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://athensga.craigslist.org/\"><b>athens, GA craigslist</b></a> &gt;for sale / wanted &gt;furniture - by owner &gt;create posting<br></section><br clear=\"all\"></header><section class=\"body\"><div class=\"posting shadow fuo\"><div class=\"formnote\"><ul><li>you can add up to 24 images to this posting.</li><li>upload best image first &mdash;it will be featured.</li></ul></div><div class=\"imguploadbuttons\"><div class=\"addmore\"><form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\" enctype=\"multipart/form-data\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18xOTQ1MDE5NEAD71NRxn4CCRBdhcU3Ikhv0WIn7uIJm3X3lIvOedEB_SuqkKO6fZA\"><input type=\"hidden\" name=\"a\" value=\"add\"><input class=\"file\" type=\"file\" name=\"file\" multiple=\"multiple\"><button class=\"add\" type=\"submit\" name=\"go\" value=\"add image\">add image</button></form></div></div><br><br><div class=\"images\"><br><br style=\"clear:both;\"></div></div><form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18xOTQ1MDE5NEAD71NRxn4CCRBdhcU3Ikhv0WIn7uIJm3X3lIvOedEB_SuqkKO6fZA\"><input type=\"hidden\" name=\"a\" value=\"fin\"><button class=\"done bigbutton\" tabindex=\"1\" type=\"submit\" name=\"go\" value=\"Done with Images\">done with images</button></form><script type=\"text/javascript\" src=\"//www.craigslist.org/js/postingForm.js?v=d973eb54bdd0f831f53bb88946381fff\" ></script></section>";
}

- (NSString *) sampleReviewHtml {
    return @"<!DOCTYPE html><html class=\"nojs\"><head><base href=\"https://post.craigslist.org\"><title>athens, GA craigslist | create posting</title><meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\"><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=1\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/clnew.css?v=ea10f746e3f02f1250ccc168f08223fc\"><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/jquery-ui-1.9.2.custom.css?v=cb67f2e720fe8a2c7d83234590b2d1ed\"><!--[if lt IE 9]><script type=\"text/javascript\" src=\"//www.craigslist.org/js/html5shiv.js?v=ed7af45dcbda983c8455631037ebcdda\" ></script><![endif]--><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet-stock.css?v=3253c5512da7fc3c3c1dd35eae4ccf96\"><!--[if lte IE 8]><link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"//www.craigslist.org/styles/leaflet.ie.css?v=90b6a78525e3625dd48b1917cf28076f\"><![endif]--><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-1.9.1.js?v=56eaef3b8a28d9d45bb4f86004b0eaae\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery-ui-1.9.2.custom.js?v=32c38510c8db71f2fbef00da891aeaac\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery.timeago.js?v=85680edbac82b3e4f89d919796777ec4\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/formats.js?v=5073b3dc61c933687ba35b2a7b84506e\" ></script><script type=\"text/javascript\"><!--var areaAbb=\"ahn\";--></script><script type=\"text/javascript\"><!--var lsDomain=\"www\";--></script></head><body class=\"post\"><script type=\"text/javascript\"><!--function C(k){return(document.cookie.match('(^|;)'+k+'=([^;]*)')||0)[2]}var pagetype, pagemode;(function(){var h=document.documentElement;h.className=h.className.replace('nojs', '');var b=document.body;var bodyClassList=b.className.split(/\\s+/);;pagetype=bodyClassList[0];var fmt=C('cl_fmt');if (fmt){pagemode=fmt;bodyClassList.push(fmt);}else if (screen.width <=480){pagemode='mobile';bodyClassList.push(pagemode);}var width=window.innerWidth || document.documentElement.clientWidth;if (width > 1000){bodyClassList.push('w1024');}if (typeof catType !=='undefined'){var mode=(decodeURIComponent(C('cl_img') || '').match(new RegExp(catType + ':([^,]+)', 'i')) ||{})[1];for (var i=0, len=bodyClassList.length;i < len;i++){if (bodyClassList[i]==='map'){mode=undefined;}}if (mode){bodyClassList.push(mode);}}b.className=bodyClassList.join(' ');}());--></script><article id=\"pagecontainer\"><header class=\"bchead\"><section class=\"contents\"><aside id=\"accountBlurb\" class=\"highlight\"><font face=\"sans-serif\"><b><a href=\"https://accounts.craigslist.org/login?rt=P&amp;rp=/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\">log in to your account</a></b><br><a href=\"https://accounts.craigslist.org/signup?rt=P&amp;rp=%2Fk%2FMMLXnfx04xGKTm7mNMTI0w%2Fk8tWJ\"><small>(Apply for Account)</small></a></font></aside><a href=\"http://athensga.craigslist.org/\"><b>athens, GA craigslist</b></a> &gt;for sale / wanted &gt;furniture - by owner &gt;create posting<br><i>Your posting will expire from the site in 45 days.</i></section><br clear=\"all\"></header><section class=\"body\"><div class=\"draft_warning\"> this is an unpublished draft. <form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18yMjMwOTIyM3mXu5rrSYcSriWKLubXTKoteEqhma_g9FISNe0QeO45PC5gZDnVCYg\"><input type=\"hidden\" name=\"continue\" value=\"y\"><button class=\"button\" type=\"submit\" tabindex=\"1\" name=\"go\" value=\"Continue\">publish</button></form></div><div class=\"posting shadow\"><header class=\"bchead\"><div class=\"contents closed\"><div class=\"breadbox\"><div class=\"mi post\"><em>[ </em><a href=\"https://post.craigslist.org/c/cl::data::Area=HASH(0x7fe03fa0fd70)->abbreviation\">post</a><em>]</em></div><div class=\"mi account\"><em>[ </em><a href=\"https://accounts.craigslist.org\">account</a><em>]</em></div><div class=\"mi fav\"><div id=\"favorites\"><a href=\"#\" class=\"favlink\"><span class=\"n\">0</span> favorites</a></div></div><span class=\"crumb\"><a href=\"//www.craigslist.org/about/sites\">CL</a> &gt;</span><span class=\"crumb\">athens, GA &gt;</span><span class=\"crumb\">for sale / wanted &gt;</span><span class=\"crumb\">furniture - by owner</span></div><div class=\"dropdown\">&mdash;&mdash;&mdash;</div></div></header><br><section class=\"dateReplyBar\"><script type=\"text/javascript\"><!--var isPreview=\"1\";var bestOf=\"\";var buttonPostingID=\"_MMLXnfx04xGKTm7mNMTI0w\";--></script><button class=\"reply_button\">reply <span class=\"envelope\">&#9993;</span><span class=\"phone\">&#9742;</span></button><span class=\"replylink\"><a href=\"/reply/_MMLXnfx04xGKTm7mNMTI0w\">reply</a></span><div class=\"returnemail\"></div><p class=\"postinginfo\">Posted: <time datetime=\"2014-01-04T00:24:01-0500\">2014-01-04 12:24am</time></p></section><h2 class=\"postingtitle\"><span class=\"star\"></span> Random Books</h2><section class=\"userbody\"><script type=\"text/javascript\"><!-- imgList=[\"https://post.craigslist.org/imagepreview/01313_hE5OOk5X0jE_600x450.jpg\",\"https://post.craigslist.org/imagepreview/00b0b_cukK6LzYZWE_600x450.jpg\"];// --></script><figure class=\"iw\"><div id=\"ci\"><img id=\"iwi\" src=\"https://post.craigslist.org/imagepreview/01313_hE5OOk5X0jE_600x450.jpg\" alt=\"\" title=\"image 1\"></div><div id=\"thumbs\"><a href=\"https://post.craigslist.org/imagepreview/01313_hE5OOk5X0jE_600x450.jpg\" title=\"1\"><img src=\"https://post.craigslist.org/imagepreview/01313_hE5OOk5X0jE_50x50c.jpg\" class=\"selected\" alt=\"image 1\"></a><a href=\"https://post.craigslist.org/imagepreview/00b0b_cukK6LzYZWE_600x450.jpg\" title=\"2\"><img src=\"https://post.craigslist.org/imagepreview/00b0b_cukK6LzYZWE_50x50c.jpg\" alt=\"image 2\"></a></div></figure><div class=\"mapAndAttrs\"></div><section id=\"postingbody\">A bunch of books to get rid of.</section><section class=\"cltags\"><ul class=\"blurbs\"><li>do NOT contact me with unsolicited services or offers</li></ul></section><div class=\"postinginfos\"><p class=\"postinginfo\">posted: <time datetime=\"2014-01-04T00:24:01-0500\">2014-01-04 12:24am</time></p><p class=\"postinginfo\"><a href=\"https://accounts.craigslist.org/eaf?\" class=\"tsb\">email to friend</a></p><p class=\"postinginfo\"><a class=\"bestoflink\" data-flag=\"9\" href=\"https://post.craigslist.org/flag?flagCode=9&amp;postingID=\" title=\"nominate for best-of-CL\"><span class=\"bestof\">&hearts;</span><span class=\"bestoftext\">best of</span></a></p></div></section><aside class=\"tsb\"><p><a href=\"//www.craigslist.org/about/scams\">Avoid scams, deal locally</a><em>Beware wiring (e.g. Western Union), cashier checks, money orders, shipping.</em><br></aside></div><section id=\"previewButtons\"><form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18yMjMwOTIyM3mXu5rrSYcSriWKLubXTKoteEqhma_g9FISNe0QeO45PC5gZDnVCYg\"><input type=\"hidden\" name=\"continue\" value=\"y\"><button class=\"bigbutton\" type=\"submit\" tabindex=\"1\" name=\"go\" value=\"Continue\">publish</button></form><form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18yMjMwOTIyM3mXu5rrSYcSriWKLubXTKoteEqhma_g9FISNe0QeO45PC5gZDnVCYg\"><input type=\"hidden\" name=\"continue\" value=\"n\"><button type=\"submit\" tabindex=\"1\" name=\"go\" value=\"Edit Text\">edit text</button></form><form action=\"https://post.craigslist.org/k/MMLXnfx04xGKTm7mNMTI0w/k8tWJ\" method=\"post\"><input type=\"hidden\" name=\"cryptedStepCheck\" value=\"U2FsdGVkX18yMjMwOTIyM3mXu5rrSYcSriWKLubXTKoteEqhma_g9FISNe0QeO45PC5gZDnVCYg\"><input type=\"hidden\" name=\"continue\" value=\"i\"><button type=\"submit\" tabindex=\"1\" name=\"go\" value=\"Edit Images\">edit images</button></form></section></section><script type=\"text/javascript\"><!--var pID=null;var wwwurl=\"http://www.craigslist.org\";--></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/jquery.timeago.js?v=85680edbac82b3e4f89d919796777ec4\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/swipe.js?v=b9534214d2dc51e408cc6fb2dd26ca45\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/postings.js?v=0ef01ee0f08afce3a82e77611ee210dd\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/leaflet-cl.js?v=1d2408493f943d8db10b845f099d2791\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/mapsConfig.js?v=5775726168f4ff14bde5d6b8bedb36f3\" ></script><script type=\"text/javascript\" src=\"//www.craigslist.org/js/simpleMaps.js?v=12675897ab12d54ca8a9d93b06fa32d1\" ></script>";
}

@end
