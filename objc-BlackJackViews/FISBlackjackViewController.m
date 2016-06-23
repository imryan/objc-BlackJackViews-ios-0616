//
//  FISBlackjackViewController.m
//  objc-BlackJackViews
//
//  Created by Ryan Cohen on 6/20/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#import "FISBlackjackViewController.h"

@interface FISBlackjackViewController ()

@property (weak, nonatomic) IBOutlet UILabel *houseLabel;
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (weak, nonatomic) IBOutlet UILabel *houseScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseStayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseBustLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseBlackjackLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *houseLossesLabel;

@property (weak, nonatomic) IBOutlet UILabel *houseCard1Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard2Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard3Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard4Label;
@property (weak, nonatomic) IBOutlet UILabel *houseCard5Label;

@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStayedLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerCard1Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard2Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard3Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard4Label;
@property (weak, nonatomic) IBOutlet UILabel *playerCard5Label;

@property (weak, nonatomic) IBOutlet UILabel *playerBustLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerBlackjackLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerLossesLabel;

@property (weak, nonatomic) IBOutlet UIButton *dealButton;
@property (weak, nonatomic) IBOutlet UIButton *hitButton;
@property (weak, nonatomic) IBOutlet UIButton *stayButton;

@property (nonatomic, strong) NSArray *houseCards;
@property (nonatomic, strong) NSArray *playerCards;

- (IBAction)hit:(id)sender;
- (IBAction)stay:(id)sender;
- (IBAction)deal:(id)sender;

@end

@implementation FISBlackjackViewController

#pragma mark - Actions

- (IBAction)hit:(id)sender {
    if (self.game.player.busted) {
        self.playerBustLabel.hidden = NO;
    } else {
        [self.game dealCardToPlayer];
        [self unhideCardForPlayer:@"player"];
        [self updateScoreFor:@"player"];
    }
    
    self.hitButton.enabled = NO;
    self.stayButton.enabled = NO;
    
    [self.game processHouseTurn];
    [self unhideCardForPlayer:@"house"];

    self.hitButton.enabled = YES;
    self.stayButton.enabled = YES;
    
    [self updateActiveLabels];
    [self checkGameStatus];
}

- (IBAction)stay:(id)sender {
    self.game.player.stayed = YES;
    self.hitButton.enabled = NO;
    self.stayButton.enabled = NO;
    
    [self.game processHouseTurn];
    
    self.hitButton.enabled = NO;
    self.stayButton.enabled = NO;
    
    [self checkGameStatus];
}

- (void)resetGameState {
    [self.game.player resetForNewGame];
    [self.game.house resetForNewGame];
    
    self.playerStayedLabel.hidden = YES;
    self.playerBustLabel.hidden = YES;
    self.playerBlackjackLabel.hidden = YES;
    
    self.houseStayedLabel.hidden = YES;
    self.houseBustLabel.hidden = YES;
    self.houseBlackjackLabel.hidden = YES;
    
    self.winnerLabel.hidden = YES;
    
    [self hideCards:YES];
}

- (IBAction)deal:(id)sender {
    [self resetGameState];
    
    [self.game playBlackjack];
    
    self.dealButton.enabled = NO;
    self.hitButton.enabled = YES;
    self.stayButton.enabled = YES;

    for (NSUInteger i = 0; i < 2; i++) {
        NSString *playerCardLabel = [self.game.player.cardsInHand[i] description];
        NSString *houseCardLabel = [self.game.house.cardsInHand[i] description];
        
        UILabel *playerLabel = self.playerCards[i];
        playerLabel.hidden = NO;
        
        UILabel *houseLabel = self.houseCards[i];
        houseLabel.hidden = NO;
        
        playerLabel.text = playerCardLabel;
        houseLabel.text = houseCardLabel;
    }
    
    [self updateScoreFor:@"player"];
    [self updateScoreFor:@"house"];
    
    [self checkGameStatus];
}

#pragma mark - Helpers

- (void)hideCards:(BOOL)hide {
    for (UILabel *label in self.houseCards) {
        label.hidden = hide;
    }
    
    for (UILabel *label in self.playerCards) {
        label.hidden = hide;
    }
}

- (void)updateScoreFor:(NSString *)player {
    if ([player isEqualToString:@"player"]) {
        self.playerScoreLabel.hidden = NO;
        self.playerScoreLabel.text = [NSString stringWithFormat:@"Score: %lu", self.game.player.handscore];
    } else {
        self.houseScoreLabel.hidden = NO;
        self.houseScoreLabel.text = [NSString stringWithFormat:@"Score: %lu", self.game.house.handscore];
    }
}

- (void)updateWinsForPlayer {
    self.game.player.wins++;
    self.playerWinsLabel.text = [NSString stringWithFormat:@"Wins: %lu", self.game.player.wins];
    
    self.game.house.losses++;
    self.houseLossesLabel.text = [NSString stringWithFormat:@"Losses: %lu", self.game.house.losses];
}

- (void)updateWinsForHouse {
    self.game.house.wins++;
    self.houseWinsLabel.text = [NSString stringWithFormat:@"Wins: %lu", self.game.house.wins];
    
    self.game.player.losses++;
    self.playerLossesLabel.text = [NSString stringWithFormat:@"Losses: %lu", self.game.player.losses];
}

- (void)unhideCardForPlayer:(NSString *)player {
    if ([player isEqualToString:@"player"]) {
        for (UILabel *label in self.playerCards) {
            if (label.hidden) {
                label.text = [[self.game.player.cardsInHand lastObject] description];
                label.hidden = NO;
                break;
            }
        }
        
    } else {
        for (UILabel *label in self.houseCards) {
            if (label.hidden) {
                label.text = [[self.game.house.cardsInHand lastObject] description];
                label.hidden = NO;
                break;
            }
        }
    }
}

- (void)updateActiveLabels {
    self.playerBustLabel.hidden = !self.game.player.busted;
    self.playerStayedLabel.hidden = !self.game.player.stayed;
    self.playerBlackjackLabel.hidden = !self.game.player.blackjack;
    
    self.houseBustLabel.hidden = !self.game.house.busted;
    self.houseStayedLabel.hidden = !self.game.house.stayed;
    self.houseBlackjackLabel.hidden = !self.game.house.blackjack;
}

- (void)checkGameStatus {
    if (self.game.player.busted) {
        self.playerBustLabel.hidden = NO;
        
        self.hitButton.enabled = NO;
        self.stayButton.enabled = NO;
        
        self.winnerLabel.hidden = NO;
        self.winnerLabel.text = @"House";
        self.dealButton.enabled = YES;
        
        [self updateWinsForHouse];
        
    } else if (self.game.player.blackjack) {
        self.playerBlackjackLabel.hidden = NO;
        
        self.hitButton.enabled = NO;
        self.stayButton.enabled = NO;
        
        self.winnerLabel.hidden = NO;
        self.winnerLabel.text = @"Player";
        self.dealButton.enabled = YES;
        
        [self updateWinsForPlayer];
        
    } else if (self.game.player.stayed) {
        self.winnerLabel.hidden = NO;
        self.playerStayedLabel.hidden = NO;
    }
    
    if (self.game.house.busted) {
        self.houseBustLabel.hidden = NO;
        
        self.hitButton.enabled = NO;
        self.stayButton.enabled = NO;
        
        self.winnerLabel.hidden = NO;
        self.winnerLabel.text = @"Player";
        self.dealButton.enabled = YES;
        
        [self updateWinsForPlayer];
        
    } else if (self.game.house.blackjack) {
        self.houseBlackjackLabel.hidden = NO;
        
        self.hitButton.enabled = NO;
        self.stayButton.enabled = NO;
        
        self.winnerLabel.hidden = NO;
        self.winnerLabel.text = @"House";
        self.dealButton.enabled = YES;
        
        [self updateWinsForHouse];
        
    } else if (self.game.house.stayed) {
        self.winnerLabel.hidden = NO;
        self.houseStayedLabel.hidden = NO;
    }
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.houseCards = @[self.houseCard1Label,
                        self.houseCard2Label,
                        self.houseCard3Label,
                        self.houseCard4Label,
                        self.houseCard5Label];
    
    self.playerCards = @[self.playerCard1Label,
                         self.playerCard2Label,
                         self.playerCard3Label,
                         self.playerCard4Label,
                         self.playerCard5Label];
    
    [self hideCards:YES];
    [self updateActiveLabels];
    
    self.winnerLabel.hidden = YES;
    
    self.houseScoreLabel.hidden = YES;
    self.playerScoreLabel.hidden = YES;
    
    self.game = [FISBlackjackGame new];
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

@end
