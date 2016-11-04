//
//  ViewController.m
//  cn.com.fcrow
//
//  Created by Fog Crow on 16/10/22.
//  Copyright © 2016年 Fcrow. All rights reserved.
//
#import "ViewController.h"
//拖拽按钮的高度
#define dragBottomLength 40.0
//dragView充满View时。 上端的可编辑区域 selectView.size.height
#define dragTipBtnLength 100.0
//dragView充满View时。 title的高度
#define titleHight 64.0

#define cellHight 120.0
#define BOUNDS [[UIScreen mainScreen] bounds]


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    bool selfFlag;
    
    UILabel *searchLabel; //最上方search上的字；
    UITextField *searchField;//search输入框；
    
    
    
    NSArray *titleArr;
   
    UIView *dragView;  //可拖拽区域
    UITableView *dragTableView; //拖拽区域内的tableView
    UIView *selectView;   // 可拖拽区域的上部
    CGPoint orginalTouchLocation;
    
    CGPoint orginalLocation;
    CGFloat orginDragViewY;  //中间时dragView.orgin.y
    CGFloat topDragViewY; //最顶部时dragView.orgin.y
    CGFloat bottominDragViewY; //最底部时dragView.orgin.y
    UIView *titleView;
    
    UIView *blackView;
    
    
    
    UITableView *dropTableView;
}

@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    orginDragViewY =BOUNDS.size.height *0.5;
    topDragViewY = titleHight;
    bottominDragViewY =BOUNDS.size.height - dragBottomLength;
    
    
    
    
    [self creatSearchView];
    [self createView];
    [self createTitleView];
    
    
    
    
    // Do any additional setup after loading the view.
    
}


-(void)createTitleView
{
    titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 64)];
    titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleView];
    
    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(0, 0.5*(titleHight-40)+5, BOUNDS.size.width, 40)];
    title.text = @"查询";
    title.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:title];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 0.5*(titleHight-35)+5, 35, 35)];
    [backButton setImage:[UIImage imageNamed:@"left@3x"] forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeLeft;
    
    [titleView addSubview:backButton];
    titleView.alpha = 0.0;
}
#pragma mark- 页面最上方的search按钮
- (void)creatSearchView{
    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, BOUNDS.size.width, 60)];
    searchBgView.backgroundColor = [UIColor clearColor];//lightGrayColor
    [self.view addSubview:searchBgView];
    
    UIButton *searchInput = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, BOUNDS.size.width - 20, 40)];
    [searchInput setImage:[UIImage imageNamed:@"searchBG"] forState:UIControlStateNormal];
    
    searchInput.adjustsImageWhenHighlighted = NO;
    [searchBgView addSubview:searchInput];
    
    
    
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, BOUNDS.size.width - 50, 20)];
    searchLabel.text = @"尝试搜索理财，基金产品";
    searchLabel.textColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
    searchLabel.font = [UIFont systemFontOfSize:13.0];
    [searchInput addSubview:searchLabel];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"left@3x"]  forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeLeft;
    
    [searchBgView addSubview:backButton];
    
    UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(searchBgView.frame)-60, 10, 40, 40)];
    [clearButton setImage:[UIImage imageNamed:@"close@3x.png"] forState:UIControlStateNormal];
    clearButton.imageView.contentMode   = UIViewContentModeScaleAspectFit;
    
    
    [searchBgView addSubview:clearButton];
    
}


-(void)searchInput
{
    selectView.frame = CGRectMake(0, 0, BOUNDS.size.width, CGRectGetHeight(selectView.frame));
    selectView.backgroundColor = [UIColor redColor];
    titleView.alpha = 1.0 ;
    dragView.frame = CGRectMake(0,topDragViewY,BOUNDS.size.width,BOUNDS.size.height-titleHight);
    dragTableView.frame = CGRectMake(0, dragTipBtnLength, BOUNDS.size.width, BOUNDS.size.height  -CGRectGetMinY(dragTableView.frame) - topDragViewY );
    
    
//    [searchField becomeFirstResponder];
    
}

#pragma mark--配置拖拽view
-(void)createView
{
    dragView =[[UIView alloc]initWithFrame:CGRectMake(0, orginDragViewY, BOUNDS.size.width, BOUNDS.size.height-titleHight)];
    dragView.backgroundColor = [UIColor clearColor];
    
    
    selectView = [[UIView alloc]initWithFrame:CGRectMake(0, dragBottomLength , BOUNDS.size.width, 100)];
    selectView.backgroundColor=[UIColor whiteColor];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, dragBottomLength)];
    imgView.image = [UIImage imageNamed:@"dropBox.png"];
    [dragView addSubview:imgView];
    
    [self creatDownDropView];
    
    
    //    UIView *searchView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 100)];
    //    selectView.backgroundColor =[UIColor blueColor];
    //    [selectView addSubview:searchView];
    
    
    
    
    [dragView addSubview:selectView];
    
    dragTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, dragBottomLength, BOUNDS.size.width, BOUNDS.size.height -CGRectGetMinY(dragView.frame)-dragBottomLength) style:UITableViewStylePlain];
    //    dragTableView.bounces = NO;
    dragTableView.delegate = self;
    dragTableView.dataSource = self;
    [dragView addSubview:dragTableView];
    [self.view addSubview:dragView];
    
}


#pragma mark---查询类型，tableView上的搜索框
-(void)creatDownDropView
{
    NSArray *array = @[@"查询类型",@"我的附近",@"全部区域"];
    for (int i = 0; i < 3; i ++) {
        float width = BOUNDS.size.width *0.33;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*width-25, 55, width, 40)];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, width-10, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0,0);
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn setImage:[UIImage imageNamed:@"arrowDown_gray.png"] forState:UIControlStateNormal];
        [btn setTitle:array[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"arrowDown_bule.png"] forState:UIControlStateSelected];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:8/255.0 green:113/255.0 blue:213/255.0 alpha:1.0] forState:UIControlStateSelected];
        btn.tag = 100*i;
        
        [selectView addSubview:btn];
        
    }
    
    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 50)];
    searchBgView.backgroundColor = [UIColor lightGrayColor];//lightGrayColor
    [self.view addSubview:searchBgView];
    UIImageView *backImg    = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, BOUNDS.size.width-10, 40)];
    
    backImg.image = [UIImage imageNamed:@"searchBG" ];
    [searchBgView addSubview:backImg];
    
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(40, 5, BOUNDS.size.width - 50, 40)];
    //    searchField.placeholder   = @"尝试搜索理财，基金产品";
    searchField.textColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
    searchField.font = [UIFont systemFontOfSize:13.0];
    searchField.userInteractionEnabled = NO;
    [searchBgView addSubview:searchField];
    
    UIImageView *smallImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 15, 15)];
    smallImage.image = [UIImage imageNamed:@"Search" ];
    [searchBgView addSubview:smallImage];
    [selectView addSubview:searchBgView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.tapCount > 1)
    {
        return;
    }else{
        CGPoint currentLocation = [touch locationInView:self.view];
        orginalLocation = currentLocation;
        orginalTouchLocation = orginalLocation;
        
    }
    
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.tapCount > 1)
    {
        return;
    }else{
        
        CGPoint currentLocation = [touch locationInView:self.view];
        CGFloat viewY = currentLocation.y - orginalLocation.y;
        //        小视图向下滑到最低，开始滑动大视图
        if (viewY > 0 || viewY == 0) {
            if (selectView.frame.origin.y > dragTipBtnLength
                ||selectView.frame.origin.y == dragTipBtnLength) {
                selectView.frame = CGRectMake(0, dragTipBtnLength, BOUNDS.size.width, BOUNDS.size.height);
                
                
                CGFloat y = dragView.frame.origin.y;
                //向下滑动，设置划动最低限
                if(dragView.frame.origin.y >BOUNDS.size.height - dragBottomLength || dragView.frame.origin.y == BOUNDS.size.height - dragBottomLength){
                    dragView.frame =CGRectMake(0, BOUNDS.size.height -dragBottomLength, BOUNDS.size.width, CGRectGetHeight(dragView.frame));
                    return;
                }
                
                dragView.frame = CGRectMake(0,y+viewY,BOUNDS.size.width,CGRectGetHeight(dragView.frame));
                
                dragTableView.frame = CGRectMake(0, CGRectGetMinY(dragTableView.frame), BOUNDS.size.width, CGRectGetHeight(dragTableView.frame)-viewY);
                orginalLocation = currentLocation;
                return;
            }
            
        }
        
        
        //        当大视图完成时，滑动小视图
        if (dragView.frame.origin.y < titleHight || dragView.frame.origin.y == titleHight) {
            dragView.frame = CGRectMake(0, titleHight, BOUNDS.size.width, BOUNDS.size.height - titleHight);
            
            //若最上端了，不允许再向上滑
            if ((selectView.frame.origin.y < 0  || selectView.frame.origin.y == 0) && currentLocation.y < orginalLocation.y) {
                selectView.frame = CGRectMake(0, 0, BOUNDS.size.width, dragTipBtnLength);
                return;
            }
            //            不是最上端，可以上滑或者下滑
            selectView.frame = CGRectMake(0, CGRectGetMinY(selectView.frame), BOUNDS.size.width, CGRectGetHeight(selectView.frame));
            
            dragView.frame = CGRectMake(0,CGRectGetMinY(dragView.frame),BOUNDS.size.width,CGRectGetHeight(dragView.frame)+viewY);
            
            
            orginalLocation = currentLocation;
            
            return;
        }else{
            selectView.frame = CGRectMake(0, CGRectGetMinY(selectView.frame), BOUNDS.size.width, dragTipBtnLength);
            
            //            /改变大视图的滑动
            CGFloat y = dragView.frame.origin.y;
            dragView.frame = CGRectMake(0,y+viewY,BOUNDS.size.width,CGRectGetHeight(dragView.frame));
            
            dragTableView.frame = CGRectMake(0, CGRectGetMinY(dragTableView.frame), BOUNDS.size.width, CGRectGetHeight(dragTableView.frame)-viewY);
            orginalLocation = currentLocation;
        }
    }
}


#pragma mark- 拖动结束后 动画进行位置移动
-(void)locationMove:(CGFloat)Y
{
    [UIView beginAnimations:nil context:nil]; // 开始动画
    if (topDragViewY == Y) {
        selectView.frame = CGRectMake(0, 0, BOUNDS.size.width, CGRectGetHeight(selectView.frame));
        titleView.alpha = 1.0 ;
        dragView.frame = CGRectMake(0,Y,BOUNDS.size.width,BOUNDS.size.height-titleHight);
        dragTableView.frame = CGRectMake(0, dragTipBtnLength, BOUNDS.size.width, BOUNDS.size.height  -CGRectGetMinY(dragView.frame) - dragTipBtnLength);
    }else {
        selectView.frame = CGRectMake(0, dragTipBtnLength, BOUNDS.size.width, CGRectGetHeight(selectView.frame));
        titleView.alpha = 0.0 ;
        dragView.frame = CGRectMake(0,Y,BOUNDS.size.width,BOUNDS.size.height-(dragTipBtnLength-dragBottomLength)-titleHight);
        dragTableView.frame = CGRectMake(0, dragBottomLength, BOUNDS.size.width, BOUNDS.size.height  -CGRectGetMinY(dragView.frame)-dragBottomLength );
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    
    
    [UIView commitAnimations]; // 提交动画
    
}


-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.tapCount > 1)
    {
        return;
    }else{
        
        CGPoint currentLocation = [touch locationInView:self.view];
        //向下滑
        if ( currentLocation.y - orginalLocation.y > 0  ) {
            if (dragView.frame.origin.y> orginDragViewY ) {
                //向下滑，最后的Y大于中间值
                [self locationMove:bottominDragViewY];
                
            }else if(dragView.frame.origin.y< orginDragViewY ){
                //向下滑，最后的Y小于中间值
                [self locationMove:orginDragViewY];
                
            }
        }
        //        向上滑
        if (currentLocation.y - orginalLocation.y < 0 ) {
            if (dragView.frame.origin.y < orginDragViewY ) {
                //向上滑，最后的Y大于中间值
                [self locationMove:topDragViewY];
                
            }else if(dragView.frame.origin.y  > orginDragViewY ){
                //向上滑，最后的Y小于中间值
                [self locationMove:orginDragViewY];
                
            }
        }
        
        
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.tapCount > 1)
    {
        return;
    }else{
        
        CGPoint currentLocation = [touch locationInView:self.view];
        //向下滑
        if ( currentLocation.y - orginalTouchLocation.y > 0  ) {
            if (dragView.frame.origin.y> orginDragViewY   ) {
                //向下滑，最后的Y大于中间值
                [self locationMove:bottominDragViewY];
                return;
                
            }else if(dragView.frame.origin.y< orginDragViewY || dragView.frame.origin.y == orginDragViewY){
                //向下滑，最后的Y小于中间值
                [self locationMove:orginDragViewY];
                return;
            }
        }
        //        向上滑
        if (currentLocation.y - orginalTouchLocation.y < 0 ) {
            if (dragView.frame.origin.y < orginDragViewY ) {
                //向上滑，最后的Y大于中间值
                [self locationMove:topDragViewY];
                return;
                
            }else if(dragView.frame.origin.y  > orginDragViewY ){
                //向上滑，最后的Y小于中间值
                [self locationMove:orginDragViewY];
                return;
                
            }
        }
        
        if (currentLocation.y   == orginalLocation.y) {
            
            if ([[NSString stringWithFormat:@"%f.2",dragView.frame.origin.y] isEqualToString:[NSString stringWithFormat:@"%f.2",orginDragViewY]] ) {
                [self locationMove:topDragViewY];
            }else if([[NSString stringWithFormat:@"%f.2",dragView.frame.origin.y] isEqualToString:[NSString stringWithFormat:@"%f.2",bottominDragViewY]]){
                [self locationMove:orginDragViewY];
            }else if([[NSString stringWithFormat:@"%f.2",dragView.frame.origin.y] isEqualToString:[NSString stringWithFormat:@"%f.2",topDragViewY]]){
                [self locationMove:orginDragViewY];
            }
            
        }
        
    }
}


#pragma mark- 顶端拖拽scrollView时，让dragView自己掉下来
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (dragView.frame.origin.y > topDragViewY) {
        return;
    }
    
    if (scrollView.contentOffset.y < - 70) {
        
        scrollView.contentOffset = CGPointMake(0, 0);
        [self locationMove:orginDragViewY];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellString =[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.row,(long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        cell.backgroundColor = [UIColor greenColor];
    }
    
    
    //    cell.contentView.backgroundColor = [UIColor clearColor];
    //    cell.backgroundColor = [UIColor clearColor];
    //    cell.textLabel.textColor = CELL_TEXTLABEL_CORLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return  cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHight;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end



