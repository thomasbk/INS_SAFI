//
//  GraficosPageViewController.m
//  INSValores
//
//  Created by Novacomp on 3/16/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "GraficosPageViewController.h"

@interface GraficosPageViewController ()

@property (nonatomic, strong) NSMutableArray *contentData;

@end

@implementation GraficosPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Gesture left
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handlePan:)];
    [pan setEdges:UIRectEdgeLeft];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];

    self.dataSource = self;
    
    self.contentData = [[NSMutableArray alloc] init];
    
    [self createPageViewController];
    [self setupPageControl];
    
    // Logo del navigation
    [Functions putNavigationIcon:self.navigationItem];
    
    // Tint de botones
    self.navigationItem.rightBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    self.mainButtonRight.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    // Es necesario para el correcto centrado del logo del navigation
    [self.mainButtonLeft setEnabled:false];
    [self.mainButtonLeft setTintColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePan:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPageViewController
{
    // Datos de gráfico composición por mercados
    Grafico *grafico1 = [[Grafico alloc] iniciarConValores:@"Composición por mercados" Tipo:@"ME"];
    Grafico *grafico2 = [[Grafico alloc] iniciarConValores:@"Composición por calificación" Tipo:@"CA"];
    Grafico *grafico3 = [[Grafico alloc] iniciarConValores:@"Composición por moneda" Tipo:@"MO"];
    Grafico *grafico4 = [[Grafico alloc] iniciarConValores:@"Composición por emisor" Tipo:@"EM"];
    Grafico *grafico5 = [[Grafico alloc] iniciarConValores:@"Composición por plazo" Tipo:@"PL"];
    Grafico *grafico6 = [[Grafico alloc] iniciarConValores:@"Composición por instrumento" Tipo:@"IN"];
    
    [_contentData addObject:grafico1];
    [_contentData addObject:grafico2];
    [_contentData addObject:grafico3];
    [_contentData addObject:grafico4];
    [_contentData addObject:grafico5];
    [_contentData addObject:grafico6];
    
    if([_contentData count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex:self.itemIndex]];
        [self setViewControllers:startingViewControllers
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    
    [self didMoveToParentViewController:self];
}

- (void)setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor:[Functions colorWithHexString:TINT_NAVIGATION_COLOR]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[Functions colorWithHexString:@"09ADDF"]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    GraficosViewController *itemController = (GraficosViewController *)viewController;
    NSUInteger index = itemController.itemIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    
    if (index == 0) {
        return [self itemControllerForIndex:[_contentData count]-1];
    } else {
        return [self itemControllerForIndex:itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    GraficosViewController *itemController = (GraficosViewController *)viewController;
    
    NSUInteger index = itemController.itemIndex;
    if (index == NSNotFound) {
        return nil;
    }
    
    if ((index + 1) == [_contentData count]){
        return [self itemControllerForIndex:0];
    } else {
        return [self itemControllerForIndex:itemController.itemIndex+1];
    }
    
    return nil;
}

- (GraficosViewController *)itemControllerForIndex:(NSUInteger)itemIndex
{
    if (itemIndex < [_contentData count])
    {
        GraficosViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier:@"graficosController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.grafico = _contentData[itemIndex];
        pageItemController.idCuenta = _idCuenta;
        pageItemController.idPortafolio = _idPortafolio;
        
        return pageItemController;
    }
    
    return nil;
}

#pragma mark Page Indicator

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_contentData count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.itemIndex;
}

#pragma mark - Additions

- (NSUInteger)currentControllerIndex
{
    GraficosViewController *pageItemController = (GraficosViewController *) [self currentController];
    
    if (pageItemController)
    {
        return pageItemController.itemIndex;
    }
    
    return -1;
}

- (UIViewController *)currentController
{
    if ([self.viewControllers count])
    {
        return self.viewControllers[0];
    }
    
    return nil;
}

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Ir a la pantalla principal: menú de opciones
- (IBAction)clicMain:(id)sender {
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}
@end
