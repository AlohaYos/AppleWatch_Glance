
#import "GlanceController.h"


@interface GlanceController()


@property (weak, nonatomic) IBOutlet WKInterfaceLabel *upperLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *centerImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lowerLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *footerLabel;

@property (strong,nonatomic) CLLocationManager *locationManager;	// ロケーションマネージャ

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
	[super awakeWithContext:context];
	
	[_upperLabel setText:@""];
	[_lowerLabel setText:@""];
	[_footerLabel setText:@""];
}

- (void)willActivate {
	[super willActivate];
	
	// ユーザーに位置情報利用の承諾を得る
	_locationManager = [CLLocationManager new];
	_locationManager.delegate = self;
	_locationManager.activityType = CLActivityTypeFitness;
	_locationManager.distanceFilter = kCLDistanceFilterNone;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[_locationManager startUpdatingLocation];
	[_locationManager startUpdatingHeading];
	
	[self sendToAppMain];
}

- (void)didDeactivate {
	
	[super didDeactivate];
}

#pragma mark - Location manager delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	// 現在位置を取得
	CLLocation *location = [locations firstObject];
	[self ReverseGeocoding:location];
	
	// 進行方向を表示
	int imageNo = location.course / 10;
	NSString *imageName = [NSString stringWithFormat:@"arrow-%d.png", imageNo];
	[_centerImage setImageNamed:imageName];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	
	// 方位を表示
	[_centerImage setImage:[self rotateImage:[UIImage imageNamed:@"arrow"] degree:newHeading.trueHeading]];
	
}

// 緯度経度から住所を取得
- (void)ReverseGeocoding:(CLLocation *)location {
	
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if(error) {
			NSLog(@"場所が特定できません");
		} else {
			if(placemarks[0]) {
				CLPlacemark *placemark = placemarks[0];
				NSString *geoString1 = [NSString stringWithFormat:@"%@", placemark.name];
				NSString *geoString2 = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
				NSString *geoString3 = [NSString stringWithFormat:@"%@, %@ %@", placemark.administrativeArea, placemark.country, placemark.postalCode];
				
				[_upperLabel setText:geoString1];
				[_lowerLabel setText:geoString2];
				[_footerLabel setText:geoString3];
			}
			
#if 0
			if(0 < [placemarks count]) {
				for(CLPlacemark *placemark in placemarks) {
					//		NSLog(@"addressDictionary: [%@]", [placemark.addressDictionary description]);
					NSLog(@"name: [%@]", placemark.name);
					NSLog(@"thoroughfare: [%@]", placemark.thoroughfare);
					NSLog(@"subThoroughfare: [%@]", placemark.subThoroughfare);
					NSLog(@"locality: [%@]", placemark.locality);
					NSLog(@"subLocality: [%@]", placemark.subLocality);
					NSLog(@"administrativeArea: [%@]", placemark.administrativeArea);
					NSLog(@"subAdministrativeArea: [%@]", placemark.subAdministrativeArea);
					NSLog(@"postalCode: [%@]", placemark.postalCode);
					NSLog(@"ISOcountryCode: [%@]", placemark.ISOcountryCode);
					NSLog(@"country: [%@]", placemark.country);
					NSLog(@"inlandWater: [%@]", placemark.inlandWater);
					NSLog(@"ocean: [%@]", placemark.ocean);
					NSLog(@"areasOfInterest: [%@]", placemark.areasOfInterest);
					NSLog(@"----------");
					NSLog(@"address:%@%@%@%@%@", placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare, placemark.subThoroughfare);
				}
			}
#endif
		}
	}];
}

// 画像を回転させる
- (UIImage*)rotateImage:(UIImage*)image degree:(int)degree {
	
	CGSize imgSize = {image.size.width, image.size.height};
	UIGraphicsBeginImageContext(imgSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, image.size.width/2, image.size.height/2); // 回転の中心点を移動
	CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
	
	float radian = -degree * M_PI / 180; // 回転
	CGContextRotateCTM(context, radian);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-image.size.width/2, -image.size.height/2, image.size.width, image.size.height), image.CGImage);
	
	UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return rotatedImage;
}

#pragma mark - Send Informatin to Main InterfaceController

- (void)sendToAppMain {
	
	NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
	[self updateUserActivity:@"com.newtonjapan.Nearbymap.glance" userInfo:@{@"param":@"launchFromGlance"} webpageURL:url];
//	[self updateUserActivity:@"com.newtonjapan.Nearbymap.glance" userInfo:@{@"param":@"launchFromGlance"} webpageURL:nil];
}

@end

