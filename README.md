NEPageView
==========

simple pageView for IOS

- (void)viewDidLoad {
    [super viewDidLoad];

    _pageView = [[NEPageView alloc] initWithFrame:self.view.bounds];
    _pageView.dataSource = self;
    [self.view addSubview:_pageView];
    self.view.backgroundColor = [UIColor orangeColor];
}


#pragma mark NEPageViewDataSource

-(UIView*)pageView:(NEPageView*)pageView pageForIndex:(NSUInteger)index {
    UIView* view = [pageView dequePage];
    if(!view) {
        view = [UIView new];
    }
    switch (index) {
    case 0:
        view.backgroundColor = [UIColor greenColor];
        break;
    case 1:
        view.backgroundColor = [UIColor blackColor];
        break;
    case 2:
        view.backgroundColor = [UIColor blueColor];
        break;
    case 3:
        view.backgroundColor = [UIColor cyanColor];
        break;
    case 4:
        view.backgroundColor = [UIColor redColor];
        break;
    case 5:
        view.backgroundColor = [UIColor greenColor];
        break;
    default:
        break;
    }
    return view;
}

-(NSUInteger)pageCount:(NEPageView*)pageView {
    return 6;
}

