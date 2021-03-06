<?php

class Auction {
    public int $AuctionId;    
    public string $StartDate;
    public string $EndDate;
    public int $Status;
    
    public int $GameId;
    public string $GameName;
    public string $GameDescription;

    public ?int $HighestBidId;
    public ?int $HighestBidBuyerId;
    public int $HighestBidAmount;
    public ?string $HighestBidBuyerUserName;
    public ?string $HighestBidDate;

    public int $Claimed=0;
}