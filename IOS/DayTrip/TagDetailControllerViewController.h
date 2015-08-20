
#import <UIKit/UIKit.h>

@class DTPOI;

@interface TagDetailControllerViewController : UITableViewController

@property (strong, nonatomic) DTPOI* poi;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@end
