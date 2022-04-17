-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Feb 09, 2022 at 11:49 AM
-- Server version: 5.7.31
-- PHP Version: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `marau`
--
CREATE DATABASE IF NOT EXISTS `marau` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `marau`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `Add_Account`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Account` (IN `Username` VARCHAR(50), IN `fName` VARCHAR(100), IN `mName` VARCHAR(100), IN `lName` VARCHAR(100), IN `PasswordHash` VARCHAR(256), IN `EmailAddress` VARCHAR(256), IN `Gender` CHAR(1), IN `BirthDate` DATE, IN `AccountType` INT, IN `Country` VARCHAR(100), IN `ContactEmail` VARCHAR(256), IN `addID` INT)  BEGIN

declare Account_ID int;

declare Last_ID int;

INSERT INTO accounts(Username, fName,mName,lName, PasswordHash, EmailAddress, Gender, BirthDate,Status) 

VALUES (Username,fName,mName,lName,PasswordHash, EmailAddress,Gender,BirthDate,0);



set Account_ID = LAST_INSERT_ID();



if AccountType = 0 then



insert into buyers(AccountId,Country,ContactEmail,Strikes,Balance) values (Account_ID,Country,ContactEmail,0,0);

set Last_ID = LAST_INSERT_ID();



elseif AccountType=1 then

insert into sellers(AccountId,Country,ContactEmail,Strikes,Balance) values (Account_ID,Country,ContactEmail,0,0);

set Last_ID = LAST_INSERT_ID();

else 

insert into moderators (AccountId,addedbyid) values (Account_ID,addID);

UPDATE accounts SET Status=1 WHERE AccountId=Account_Id;

set Last_ID = LAST_INSERT_ID();

END IF;

select Account_ID,Last_ID;

END$$

DROP PROCEDURE IF EXISTS `Add_Bid`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Bid` (IN `BidBuyerId` INT, IN `BidAuctionId` INT, IN `BidAmount` DOUBLE)  BEGIN

DECLARE _HighestBidAmount int;

DECLARE _StartDate datetime;

DECLARE _EndDate datetime;

DECLARE _BuyerId int;

DECLARE _BuyerBalance double;

SET @_CurrTime = NOW();



SELECT auction_details.HighestBidAmount, auction_details.StartDate,  auction_details.EndDate, auction_details.HighestBidBuyerId INTO _HighestBidAmount, _StartDate, _EndDate, _BuyerId FROM auction_details WHERE auction_details.AuctionId = BidAuctionId;



SELECT buyers.Balance INTO _BuyerBalance FROM buyers WHERE buyers.BuyerId = BidBuyerId;



IF (_HighestBidAmount < BidAmount AND _EndDate > @_CurrTime AND _StartDate < @_CurrTime AND _BuyerBalance >= BidAmount) THEN

	INSERT INTO bids (bids.BuyerId, bids.AuctionId, bids.BidAmount, bids.Date)

	VALUES (BidBuyerId, BidAuctionId, BidAmount, NOW());

    

    UPDATE buyers 

    SET buyers.Balance = buyers.Balance + _HighestBidAmount

    WHERE buyers.BuyerId = _BuyerId;

    

    UPDATE buyers

    SET buyers.Balance = buyers.Balance - BidAmount

    WHERE buyers.BuyerId = BidBuyerId;

    

    UPDATE auctions

    SET auctions.HighestBidId = LAST_INSERT_ID()

    WHERE auctions.AuctionId = BidAuctionId;

    

    

	SELECT LAST_INSERT_ID() AS ID;

ELSE

	SELECT -1 as ID;

END IF;

END$$

DROP PROCEDURE IF EXISTS `Add_Currency`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Currency` (`Id` INT, `amount` INT)  BEGIN
update buyers 
set Balance = Balance + amount
where BuyerId = Id;
END$$

DROP PROCEDURE IF EXISTS `Add_Game`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Game` (IN `sellerId` INT, IN `name` VARCHAR(100), IN `description` VARCHAR(250), IN `releaseDate` DATETIME, IN `price` DOUBLE, IN `version` VARCHAR(10), IN `type` VARCHAR(50), IN `sale` DOUBLE)  BEGIN

declare result int;
declare ID int;

insert into games (SellerId,Name,Description,ReleaseDate,Price,Version,Type,Sale)

values (sellerId, name, description, releaseDate, price, version, type, sale);

set ID = LAST_INSERT_ID();
INSERT INTO auctions (GameId,StartDate,EndDate)
Values (ID,now(),DATE_ADD(NOW(), INTERVAL 1 HOUR));
Select ID;

END$$

DROP PROCEDURE IF EXISTS `Add_Game_Requirements`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Game_Requirements` (`GameId` INT, `OperatingSystem` VARCHAR(50), `MinimumCPU` VARCHAR(50), `RecommendedCPU` VARCHAR(50), `MinimumGPU` VARCHAR(50), `RecommendedGPU` VARCHAR(50), `MinimumRam` INT, `RecommendedRam` INT, `Storage` INT)  BEGIN
insert into requirements 
values (GameId, OperatingSystem, MinimumCPU, RecommendedCPU, MinimumGPU, RecommendedGPU, MinimumRam, RecommendedRam, Storage);
END$$

DROP PROCEDURE IF EXISTS `Add_Review`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_Review` (`gId` INT, `bId` INT, `rText` VARCHAR(100), `rRating` DOUBLE)  BEGIN
insert into reviews 
values (gId, bId, rText, rRating);
END$$

DROP PROCEDURE IF EXISTS `Approved_By`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Approved_By` (IN `Account_ID` INT, IN `mod_id` INT)  BEGIN

UPDATE sellers set ApprovedBy=mod_id WHERE AccountId=Account_ID;

UPDATE buyers set ApprovedBy=mod_id WHERE AccountId=Account_ID;

END$$

DROP PROCEDURE IF EXISTS `AveragePriceallgames`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AveragePriceallgames` ()  BEGIN



SELECT AVG(Price) as average_price

from games;



END$$

DROP PROCEDURE IF EXISTS `BidOnAuction`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BidOnAuction` (IN `BidBuyerId` INT, IN `BidAuctionId` INT, IN `BidAmount` DOUBLE)  BEGIN

DECLARE _HighestBidAmount int;

DECLARE _EndDate datetime;

DECLARE _BuyerId int;

SELECT _HighestBidAmount = auction_details.HighestBidAmount, _EndDate = auction_details.EndDate, _BuyerId = auction_details.HighestBidBuyerId FROM auction_details WHERE auction_details.AuctionId = BidAuctionId;



INSERT INTO bids (bids.BuyerId, bids.AuctionId, bids.BidAmount, bids.Date)

	VALUES (BidBuyerId, BidAuctionId, BidAmount, NOW());

END$$

DROP PROCEDURE IF EXISTS `Change_Password`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Change_Password` (IN `Account_ID` INT, IN `_password` VARCHAR(256))  UPDATE accounts SET PasswordHash=_password WHERE Account_ID=AccountId$$

DROP PROCEDURE IF EXISTS `ClaimGame`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ClaimGame` (IN `WinnerAuctionId` INT)  BEGIN

DECLARE _BuyerId int;

DECLARE _GameId int;

DECLARE _EndDate datetime;

DECLARE _Amount double;



SELECT auction_details.HighestBidBuyerId, auction_details.GameId, auction_details.EndDate, auction_details.HighestBidAmount 
INTO _BuyerId, _GameId, _EndDate, _Amount 
FROM auction_details 
WHERE auction_details.AuctionId = WinnerAuctionId;



IF(NOW() > _EndDate) THEN
	INSERT INTO orders VALUES (_BuyerId, _GameId, _EndDate, _Amount);

	UPDATE games SET games.FirstOwner = _BuyerId WHERE games.GameId = _GameId;

	update sellers 
	set Balance = Balance + _Amount
	where SellerId = (select SellerId from games where GameId = _GameId);

END IF;

END$$

DROP PROCEDURE IF EXISTS `delete_gamebyid`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_gamebyid` (IN `id_games` INT)  BEGIN



DELETE FROM games

WHERE games.GameId = id_games;



END$$

DROP PROCEDURE IF EXISTS `delete_review`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_review` (IN `id_games` INT, IN `id_buyer` INT)  BEGIN



DELETE FROM reviews

WHERE reviews.GameId = id_games

AND reviews.BuyerId = id_buyer;



END$$

DROP PROCEDURE IF EXISTS `Edit_Account`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Edit_Account` (IN `Account_Id` INT, IN `Username` VARCHAR(50), IN `fName` VARCHAR(100), IN `mName` VARCHAR(100), IN `lName` VARCHAR(100), IN `EmailAddress` VARCHAR(256), IN `Gender` CHAR(1), IN `BirthDate` DATE, IN `AccountType` INT, IN `Country` VARCHAR(100), IN `ContactEmail` VARCHAR(256))  BEGIN



UPDATE accounts SET Username=Username,fName=fName,mName=mName,lName=lName,EmailAddress=EmailAddress, Gender=Gender, BirthDate=BirthDate 

WHERE AccountId=Account_Id;



if AccountType = 0 then



UPDATE buyers SET Country=Country,ContactEmail=ContactEmail WHERE AccountId=Account_Id;





else 

UPDATE sellers SET Country=Country,ContactEmail=ContactEmail WHERE AccountId=Account_Id;



END IF;



END$$

DROP PROCEDURE IF EXISTS `Edit_Game`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Edit_Game` (`GameId` INT, `Name` VARCHAR(100), `Description` VARCHAR(250), `ReleaseDate` DATE, `Price` DOUBLE, `Version` VARCHAR(10), `Type` VARCHAR(50), `Sale` DOUBLE)  BEGIN
update games 
set games.Name = Name ,
games.Name = Name ,
games.Description = Description ,
games.ReleaseDate = ReleaseDate ,
games.Price = Price ,
games.Version = Version ,
games.Type = Type ,
games.Sale = Sale 
where games.GameId = GameId;
END$$

DROP PROCEDURE IF EXISTS `Edit_Game_Requirements`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Edit_Game_Requirements` (`GameId` INT, `OperatingSystem` VARCHAR(50), `MinimumCPU` VARCHAR(50), `RecommendedCPU` VARCHAR(50), `MinimumGPU` VARCHAR(50), `RecommendedGPU` VARCHAR(50), `MinimumRam` INT, `RecommendedRam` INT, `Storage` INT)  BEGIN
update requirements 
set requirements.OperatingSystem = OperatingSystem, 
requirements.MinimumCPU = MinimumCPU, 
requirements.RecommendedCPU = RecommendedCPU, 
requirements.MinimumGPU = MinimumGPU, 
requirements.RecommendedGPU = RecommendedGPU, 
requirements.MinimumRam = MinimumRam, 
requirements.RecommendedRam = RecommendedRam, 
requirements.Storage = Storage
where requirements.GameId = GameId;
END$$

DROP PROCEDURE IF EXISTS `Edit_Review`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Edit_Review` (`gId` INT, `bId` INT, `rText` VARCHAR(100), `rRating` DOUBLE)  BEGIN
update reviews 
set Text = rText, 
Rating = rRating
where GameId = gId and BuyerId = bId;
END$$

DROP PROCEDURE IF EXISTS `GameCountAccordingToSeller`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GameCountAccordingToSeller` ()  BEGIN



SELECT COUNT(games.GameId) as games_count, Username

from games, sellers,accounts

WHERE games.SellerId = sellers.SellerId

AND sellers.AccountId = accounts.AccountId

GROUP BY games.SellerId ORDER by  COUNT(games.GameId) limit 10;



END$$

DROP PROCEDURE IF EXISTS `GamesCountAccordingToType`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GamesCountAccordingToType` ()  BEGIN



SELECT Type, COUNT(*) as games_count

from games

GROUP BY Type limit 10;



END$$

DROP PROCEDURE IF EXISTS `GamesOrderedByNumberOfOrders`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GamesOrderedByNumberOfOrders` ()  BEGIN



SELECT games.Name , COUNT(*) as orders_count 

from games, orders

WHERE games.GameId = orders.GameId

GROUP BY games.Name,games.GameId 

ORDER BY orders_count DESC limit 10;



END$$

DROP PROCEDURE IF EXISTS `general_statistics`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_statistics` ()  BEGIN 

SELECT (SELECT COUNT(*)

from buyers) as 'Buyers',(SELECT COUNT(*)

from sellers) as 'Sellers',(SELECT COUNT(*)

from games) as 'Games';

END$$

DROP PROCEDURE IF EXISTS `get_all_countries`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_countries` ()  BEGIN

select country,count(1) as 'Count' from Account_info group by country having Country <> "" limit 10;

END$$

DROP PROCEDURE IF EXISTS `Get_Buyer_Games`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Buyer_Games` (IN `Buyer_id` INT)  BEGIN



SELECT games_details.GameId,games_details.Name

from games_details,orders

WHERE orders.GameId = games_details.GameId

AND orders.BuyerId = Buyer_id;



END$$

DROP PROCEDURE IF EXISTS `Get_Seller_Games`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Seller_Games` (IN `Seller_id` INT)  BEGIN



SELECT games_details.GameId,games_details.Name,games_details.Rating

from games_details

WHERE games_details.SellerId = Seller_id;



END$$

DROP PROCEDURE IF EXISTS `Order_Game`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Order_Game` (`bId` INT, `gId` INT)  BEGIN
declare gamePrice int;
declare bbalance int;
IF (select count(*) from orders where BuyerId = bId and GameId = gId) = 0 then 
	set gamePrice = (select ( Price * ((100 - Sale) / 100 )) from games where GameId = gId);
	set bbalance = (select Balance from buyers where BuyerId = bId);
	IF	bbalance >= gamePrice then
		update buyers 
		set Balance = Balance - gamePrice
		where BuyerId = bId;
        
		insert into orders
		values (bId,gId,now(),gamePrice);
        
		update sellers 
		set Balance = Balance + gamePrice
		where SellerId = (select SellerId from games where GameId = gId);
        
		select 1 as ID;
	ELSE
	select 0 as ID;
	END IF;
END IF;
END$$

DROP PROCEDURE IF EXISTS `Set_Account_Status`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Set_Account_Status` (IN `Account_Id` INT, IN `S` INT)  BEGIN



UPDATE accounts SET Status=s WHERE AccountId=Account_Id;



END$$

DROP PROCEDURE IF EXISTS `Strike`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Strike` (IN `Account_ID` INT)  if EXISTS( SELECT Strikes FROM sellers WHERE AccountId=Account_ID) then UPDATE sellers set strikes=strikes+1 WHERE AccountId=Account_ID; 

elseif EXISTS( SELECT Strikes FROM buyers WHERE AccountId=Account_ID) then UPDATE buyers set strikes=strikes+1 WHERE AccountId=Account_ID;

end if$$

DROP PROCEDURE IF EXISTS `Strike_Buyer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Strike_Buyer` (IN `Buyer_Id` INT)  BEGIN



UPDATE buyers set strikes=strikes+1 WHERE BuyerId=Buyer_Id;

IF (SELECT Strikes FROM buyers WHERE buyerId=Buyer_Id)>=3 THEN

call Set_Account_Status((SELECT AccountId FROM buyers WHERE buyerId=Buyer_Id),0);

END IF;

END$$

DROP PROCEDURE IF EXISTS `Strike_Seller`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Strike_Seller` (IN `Seller_Id` INT)  BEGIN



UPDATE sellers set strikes=strikes+1 WHERE sellerId=Seller_Id;

IF (SELECT Strikes FROM sellers WHERE sellerId=Seller_Id)>=3 THEN

call Set_Account_Status((SELECT AccountId FROM sellers WHERE sellerId=Seller_Id),0);

END IF;

END$$

DROP PROCEDURE IF EXISTS `TotalBidsForEveryAuctions`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalBidsForEveryAuctions` ()  BEGIN



SELECT games.Name , COUNT(*) as bids_count 

from games, auctions,bids

WHERE games.GameId = auctions.GameId

AND bids.AuctionId = auctions.AuctionId

GROUP BY auctions.AuctionId

ORDER BY bids_count DESC limit 5;

END$$

DROP PROCEDURE IF EXISTS `TotalNumberofBuyers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalNumberofBuyers` ()  BEGIN



SELECT COUNT(*) as buyers_count

from buyers;



END$$

DROP PROCEDURE IF EXISTS `TotalNumberofGames`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalNumberofGames` ()  BEGIN



SELECT COUNT(*) as games_count

from games;



END$$

DROP PROCEDURE IF EXISTS `TotalNumberOfOrders`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalNumberOfOrders` ()  BEGIN



SELECT COUNT(*) as orders_count

from orders;



END$$

DROP PROCEDURE IF EXISTS `TotalNumberofSellers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalNumberofSellers` ()  BEGIN



SELECT COUNT(*) as sellers_count

from sellers;



END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
CREATE TABLE IF NOT EXISTS `accounts` (
  `AccountId` int(11) NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
  `fName` varchar(100) CHARACTER SET utf8mb4 DEFAULT NULL,
  `mName` varchar(100) DEFAULT NULL,
  `lName` varchar(100) DEFAULT NULL,
  `PasswordHash` varchar(256) CHARACTER SET utf8mb4 NOT NULL,
  `EmailAddress` varchar(256) NOT NULL,
  `Gender` char(1) NOT NULL,
  `BirthDate` date NOT NULL,
  `Status` char(1) DEFAULT NULL,
  PRIMARY KEY (`AccountId`),
  UNIQUE KEY `UQ_Accounts_Username` (`Username`),
  UNIQUE KEY `UQ_Email_Username` (`EmailAddress`(255))
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(7, 'Kotp911', 'Mohamed', 'Kotp', 'A', '$2y$10$E8U5E70FdNHuRFnhTWvNCusVTcZkHON6Dea1Ye6Ed8l3H1SxqxWwq', 'Kotp@gmail.com', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(9, 'Kotp123', 'Mohamed', 'Kotp', 'Amer', '$2y$10$Fu8D/MWOqPdpbHYiUiRPjuwpm2HONGVh9AWmamefpvdo3l5dFyGQi', 'Kotp911@gmail.com', 'M', '2000-01-01', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(11, 'Sakr911', 'Mohamed', 'asd', 'Kamal', '$2y$10$pnHppX0Y4JK./KpolLlUpuO3HU2Q9FGDaYnOxATebOopmaYqwIDV6', 'mahmed@gmail.com', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(12, 'Kotp12223', 'Mohamed', 'Mohamed', 'Mohamed', '$2y$10$6mX147csf8pbdVAVa0zRk.rxzsC/glWKP.cFzMpTqLxTrah2LP6XS', 'Kotp9111@gmail.coms', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(13, 'ZED', 'Mohamed', 'Kamal', 'Kamal', '$2y$10$qg55D0uV7PKvl/8obs9kIeiBX8pXDIF0HVcMKp71l6x5VqjI7B6g2', 'MASTAR@OF.THE.SHADOWS', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(14, 'testacc', 'Test', 'Testm', 'testl', '$2y$10$96KwmbuthVkCvULEUA2ceOVVPeVicPo4r5TtSEfI8rUpQW.eDVyom', 'test@test.com', 'F', '2021-12-24', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(15, 'Ahmed', 'Ahmed', 'Hany', 'Farouk', '$2y$10$Jyd/sHY.dKAvcN43n.kAwueQuVc2vC2spwYTt7RjIXkp1gvO1vAzi', 'a@12.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(16, 'Ahmed1', 'Ahmed', 'Hany', 'Farouk', '$2y$10$Eo/AQMlyNGAHuH8mjeu6IeefSnivrBzINmUaazFuZxu92NKhr75nK', 'a@1266.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(17, 'Ahmed2', 'Ahmed', 'Hany', 'Farouk', '$2y$10$sPgpRfUMzIRGQdia2kQboezfhGFUlaiYKjLT8RGC7D6mXaA2xka2W', 'a@1299.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(18, 'Ahmed3', 'Ahmed', 'Hany', 'Farouk', '$2y$10$Eq.sI1BKxQkcoavLTpGh1OY5cEZbH5rhCA2jJ/6MW9hMfCFiNOk8.', 'ahmed@e.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(20, 'tt', 'Mohamedt', 't', 't', '$2y$10$jatKdSpqIYYhM3GIyHrhnOKM/rLWS2ek2J0Xtit3jQKfVqImHzZl2', 'medoking91@gmail.comt', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(21, 'Administrator', 'General', 'Website', 'Admin', '$2y$10$EMCyFyqdW7dlK5P4xslImuHfFfA16JF.rgbQ3JWxO6VhNkj7ru9Ju', 'admin@marau.com', 'M', '2000-01-01', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(22, 'Moderator', 'Mod1', 'Mod1', 'Mod1', '$2y$10$r/EphkoO2HFYTXNKVvV4I.X9Age5zFrc.WqHdG8LtX6qHaZlVpPN.', 'Moderator@gmail.com', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(23, 'Moderator2', 'Mod2', 'Mod2', 'Mod2', '$2y$10$xmNCTIXkHzA4SGBx3IzGxeR9tFGy4qm4RkWbsARtVkQhgLwbpaT2S', 'Moderator2@gmail.com', 'M', '2021-11-28', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(24, 'buyerOne', 'buyer', 'b', 'buyer', '$2y$10$7b2v6Fs4z9J4y9eAPCjGLeTWytV9tsRBqmSPuXacxjYhE07/4h1Zm', 'test1@test.com', 'M', '2010-02-11', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(25, 'H', 'Ahmed', 'Hany', 'Farouk', '$2y$10$17Dxc3JG6HoKyHZZNfXrgePPp4ZqQ8sTl6KQFrTDiWgxOi4iGHmny', 'sadfasdf@h.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(26, 'Rand', 'Buyer', 'Test', 'Account', '$2y$10$OtUoALei/EXIdF5HHqgWLefrnkYO5VJRpGV4NfvaFHyQYYtFNb6Um', 'rand@rand.org', 'M', '2022-01-06', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(27, 'Rand2', 'Buyer', 'Test', 'Account2', '$2y$10$aeedr4ZM4mnHmT643SLkh.FfC0nR6YiNouadjqehitK9NUHL0XdDG', 'rand2@rand.org', 'M', '2022-01-06', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(28, 'Moderator3', 'Mohamed', 'Kamal', 'Othman', '$2y$10$UbX1VDvHphVjs02vTk8T3OXYAvhMR6qwpNBdB9k4CSM5WHKWAzdSe', 'mod91@gmail.com', 'M', '2000-05-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(29, 'misterX', 'Mohamed', 'Kamal', 'Moderator2', '$2y$10$LtEnPU2w.G1aCtll8BEaDuAHkOXKfDIM0ddjASQl69Mzdy2n7WQiu', 'medoking911@gmail.com', 'M', '2000-05-07', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(30, 'H123', 'Ahmed', 'Hany', 'Farouk', '$2y$10$CuruNhA/3u4dq00jZ3INlOLOtopCN98PsNlskV0.QoAih1wcDAaFm', 'sadfasdf123@h.com', 'M', '2001-11-30', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(31, 'h123b', 'Ahmed', 'Hany', 'Farouk', '$2y$10$fbizoggtt2VGVLMK0K5Ug.FrDL3d0X5mpSF9TAqIxwJpwLITrrI8O', '123@koko.com', 'M', '2022-01-07', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(33, 'Kamal', 'Mohamed', 'Kotp', 'Kamal', '$2y$10$CcSQP.avs.lS.udNQwg2J.vpMTdg0eCTwPyW4XQM2UsQ0VxLzrHVe', 'medoking921@gmail.com', 'M', '2021-12-26', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(34, 'BJohnson', 'Becky', 'J', 'Johnson', '$2y$10$vJo3It1I5WwIeKaIpkI8zuPlI5H5UaN/17w.DpraJXISlWXVi2Eti', 'joshuah_rolfs@yahoo.com', 'F', '1969-05-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(35, 'Moreland', 'Mark', 'M', 'Moreland', '$2y$10$U3fgeveC9HmRe3..K6gwsO.eBLchTLtbXkX/y/Ex5tBbYg0U.nwTK', 'cathy_prosac@gmail.com', 'M', '1989-06-20', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(36, 'Shealey99', 'Alta', 'P', 'Shealey', '$2y$10$0tOIsBCEtSZw5mUGxv/n2uJ.wNIQ1bO/wLueJBSpMvAfFwczXs1cu', 'billie1998@gmail.com', 'F', '2000-02-15', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(37, 'Brett', 'Brett', 'M', 'Ladd', '$2y$10$BVzJLEXKTXEosGv1EE3nvOLJG.Q4f3MPRc2LBLyuZAKavg1BEk3sq', 'nico_satterfie@yahoo.com', 'M', '1999-06-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(38, 'Loretta', 'Loretta', 'J', 'Gibbs', '$2y$10$flMutPTLWc6mJr0J4wBw.uryyhFPIZ3FoghL70wPtax3BGPDKAXwO', 'ariel.schuli@gmail.com', 'F', '1995-06-29', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(39, 'H12345', 'Ahmed', 'Hany', 'Farouk', '$2y$10$eQxCmLr3aiLfaHLEbSI2G.e/IyAVz7lyeOZcYXibEENz2VIrQiYbG', 'sadfasdf12395@h.com', 'M', '2022-01-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(40, 'H12399', 'Ahmed', 'Hany', 'Farouk', '$2y$10$Xft/YYa6SyfRV5R633CbWupJrz1cgKQRYOtp5NqMx2k06GPwML2Qe', '123@99.com', 'M', '2022-01-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(41, 'bobvirgo', 'Timothy', 'R', 'Alexander', '$2y$10$oY5CERcMFVmeoF/iE2Eq5OZmgm77H6UFrm7Uc7Rz.I/T63ngFbnKi', 'elijah.maye@hotmail.com', 'M', '1990-11-29', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(42, 'BigBeow55', 'Julie', 'J', 'Gallagher', '$2y$10$iitwnKLEA5.zS3ptq6eqSukF9.mKhsdzm1wTDgblRYltfDOZ33Euu', 'ally_wisok10@yahoo.com', 'F', '1981-09-27', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(43, 'garland_ok1994', 'Ethel', 'J', 'Rodriguez', '$2y$10$47PGXNBF1G1jIo4EAFZk6.U/NATJUAZPicVOD6cCH1zyrBKZ1RffC', 'aaron1979@hotmail.com', 'F', '1971-03-15', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(44, 'Rockstar', 'Rockstar', 'R', 'Games', '$2y$10$pqfeCIlqltQ8vwyY7dlo6.xSGXjTlPXAbUm9BgeVImQwho8SHbqxi', 'Admin@Rockstar.com', 'M', '1998-12-01', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(45, 'ReviewStriker', 'Reviews', 's', 'Striker', '$2y$10$4sD2hPYUH4NNuvGzEoPp0OgUz6LQq3KRV.7yNHqjywoZdbBsozon2', 'ReviewStriker@marau.com', 'M', '1990-08-09', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(46, 'CrystalDynamics', 'Crystal', 'C', 'Dynamics', '$2y$10$IdnJJcMPtXtdmpI76ogNYuIQ9YB7IALytCFR7lvd5flflAz9CGG6.', 'admin@CrystalDynamics.com', 'M', '2000-05-20', '1');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(48, 'H99', 'Ahmed', 'Hany', 'Farouk', '$2y$10$ItybWYwAqDzr7MkO64owMeePz87qbJWGhoYm/0iRCJIm/6LWXt45i', '123123@99.com', 'M', '2022-01-09', '0');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(49, 'John', 'John ', 'M', 'Hannum', '$2y$10$A9/SbY.HL61QbQjxLUXnGurIeFP46qYNMfWozZbmAKvQCYs3SfVnq', 'hasd@t.com', 'M', '1992-11-16', '0');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(50, 'hasd', 'Richard', 'E', 'Turner', '$2y$10$PUlrddb7zZiLfcBebFqGwOl1NYWjXOqjmloxHmCapX5HGBcF3cwEu', '123asd@99.com', 'M', '2022-01-04', '0');
INSERT INTO `accounts` (`AccountId`, `Username`, `fName`, `mName`, `lName`, `PasswordHash`, `EmailAddress`, `Gender`, `BirthDate`, `Status`) VALUES(51, 'HRose', 'Rose', 'G', 'Briese', '$2y$10$13BfoeWJuRPB4RyrNLg34eIY5..MhswsH5bQHr0iKnEen7FmtrYZ2', '123Rose@99.com', 'F', '2016-02-03', '0');

-- --------------------------------------------------------

--
-- Stand-in structure for view `account_info`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `account_info`;
CREATE TABLE IF NOT EXISTS `account_info` (
`AccountType` varchar(9)
,`AccountId` int(11)
,`Username` varchar(50)
,`fName` varchar(100)
,`mName` varchar(100)
,`lName` varchar(100)
,`PasswordHash` varchar(256)
,`EmailAddress` varchar(256)
,`Gender` char(1)
,`BirthDate` date
,`Status` char(1)
,`Country` varchar(100)
,`ContactEmail` varchar(256)
,`Strikes` bigint(20)
,`Balance` double
,`ID` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `AdminId` int(11) NOT NULL AUTO_INCREMENT,
  `AccountId` int(11) NOT NULL,
  PRIMARY KEY (`AdminId`),
  KEY `FK_Admins_Accounts` (`AccountId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`AdminId`, `AccountId`) VALUES(1, 21);

-- --------------------------------------------------------

--
-- Stand-in structure for view `all_orders`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `all_orders`;
CREATE TABLE IF NOT EXISTS `all_orders` (
`OrderDate` datetime(6)
,`Buyer` varchar(50)
,`Seller` varchar(50)
,`Game` varchar(100)
,`PaidAmount` double
);

-- --------------------------------------------------------

--
-- Table structure for table `auctions`
--

DROP TABLE IF EXISTS `auctions`;
CREATE TABLE IF NOT EXISTS `auctions` (
  `AuctionId` int(11) NOT NULL AUTO_INCREMENT,
  `GameId` int(11) NOT NULL,
  `HighestBidId` int(11) DEFAULT NULL,
  `StartDate` datetime(6) NOT NULL,
  `EndDate` datetime(6) NOT NULL,
  PRIMARY KEY (`AuctionId`),
  KEY `FK_Auctions_Bids` (`HighestBidId`),
  KEY `FK_Auctions_Games` (`GameId`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `auctions`
--

INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(2, 12, 8, '2022-01-05 20:51:54.000000', '2022-01-06 07:51:54.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(3, 13, 10, '2022-01-06 16:28:53.000000', '2022-01-06 15:28:53.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(5, 15, 18, '2022-01-07 15:54:46.000000', '2022-01-07 13:54:46.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(10, 20, 22, '2022-01-08 18:50:40.000000', '2022-01-08 13:50:40.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(11, 21, 25, '2022-01-09 12:46:25.000000', '2022-01-09 13:46:25.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(12, 22, 26, '2022-01-09 12:49:38.000000', '2022-01-09 13:49:38.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(13, 23, NULL, '2022-01-09 13:13:50.000000', '2022-01-09 14:13:50.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(14, 24, 27, '2022-01-09 13:15:26.000000', '2022-01-09 14:15:26.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(15, 25, 28, '2022-01-09 13:19:05.000000', '2022-01-09 14:19:05.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(16, 26, NULL, '2022-01-09 14:42:55.000000', '2022-01-09 15:42:55.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(17, 27, NULL, '2022-01-09 14:45:31.000000', '2022-01-09 15:45:31.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(18, 28, NULL, '2022-01-09 14:49:37.000000', '2022-01-09 15:49:37.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(19, 29, NULL, '2022-01-09 14:51:59.000000', '2022-01-09 15:51:59.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(20, 30, NULL, '2022-01-09 14:53:16.000000', '2022-01-09 15:53:16.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(21, 31, NULL, '2022-01-09 15:31:28.000000', '2022-01-09 16:31:28.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(22, 32, 29, '2022-01-09 15:55:16.000000', '2022-01-09 16:55:16.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(23, 33, 30, '2022-01-09 16:36:42.000000', '2022-01-09 17:36:42.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(24, 34, 31, '2022-01-09 16:39:56.000000', '2022-01-09 17:39:56.000000');
INSERT INTO `auctions` (`AuctionId`, `GameId`, `HighestBidId`, `StartDate`, `EndDate`) VALUES(25, 35, NULL, '2022-01-09 17:16:39.000000', '2022-01-09 18:16:39.000000');

-- --------------------------------------------------------

--
-- Stand-in structure for view `auction_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `auction_details`;
CREATE TABLE IF NOT EXISTS `auction_details` (
`AuctionId` int(11)
,`StartDate` datetime(6)
,`EndDate` datetime(6)
,`Status` int(2)
,`GameId` int(11)
,`GameName` varchar(100)
,`GameDescription` varchar(250)
,`HighestBidId` int(11)
,`HighestBidBuyerId` int(11)
,`HighestBidAmount` double
,`HighestBidBuyerUserName` varchar(50)
,`HighestBidDate` datetime(6)
);

-- --------------------------------------------------------

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
CREATE TABLE IF NOT EXISTS `bids` (
  `BidId` int(11) NOT NULL AUTO_INCREMENT,
  `BuyerId` int(11) NOT NULL,
  `AuctionId` int(11) NOT NULL,
  `BidAmount` double NOT NULL,
  `Date` datetime(6) NOT NULL,
  PRIMARY KEY (`BidId`),
  KEY `FK_Bids_Auctions` (`AuctionId`),
  KEY `FK_Bids_Buyers` (`BuyerId`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bids`
--

INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(2, 5, 2, 123, '2022-01-05 21:41:12.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(3, 5, 2, 1234, '2022-01-05 21:41:37.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(4, 7, 2, 234, '2022-01-06 12:49:46.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(5, 8, 2, 400, '2022-01-06 12:55:54.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(6, 8, 2, 500, '2022-01-06 12:57:25.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(7, 8, 2, 600, '2022-01-06 13:03:17.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(8, 7, 2, 700, '2022-01-06 13:04:35.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(9, 7, 3, 1500, '2022-01-06 16:44:25.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(10, 8, 3, 5000, '2022-01-06 16:44:46.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(15, 7, 5, 1231, '2022-01-07 16:02:18.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(16, 6, 5, 2000, '2022-01-07 16:03:35.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(17, 7, 5, 2001, '2022-01-07 16:03:53.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(18, 6, 5, 2003, '2022-01-07 16:05:18.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(19, 6, 10, 3000, '2022-01-08 18:50:59.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(20, 9, 10, 3001, '2022-01-08 18:52:21.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(21, 6, 10, 20221, '2022-01-08 18:52:50.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(22, 9, 10, 20222, '2022-01-08 18:53:40.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(23, 10, 12, 12, '2022-01-09 13:06:05.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(24, 10, 11, 123, '2022-01-09 13:06:30.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(25, 12, 11, 1234, '2022-01-09 13:23:09.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(26, 12, 12, 1090, '2022-01-09 13:23:28.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(27, 12, 14, 10000, '2022-01-09 13:23:51.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(28, 12, 15, 6000, '2022-01-09 13:23:58.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(29, 10, 22, 1234, '2022-01-09 16:49:20.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(30, 10, 23, 1500, '2022-01-09 16:49:31.000000');
INSERT INTO `bids` (`BidId`, `BuyerId`, `AuctionId`, `BidAmount`, `Date`) VALUES(31, 5, 24, 1, '2022-01-09 17:21:48.000000');

-- --------------------------------------------------------

--
-- Table structure for table `buyers`
--

DROP TABLE IF EXISTS `buyers`;
CREATE TABLE IF NOT EXISTS `buyers` (
  `BuyerId` int(11) NOT NULL AUTO_INCREMENT,
  `AccountId` int(11) NOT NULL,
  `ApprovedBy` int(11) DEFAULT NULL,
  `Country` varchar(100) NOT NULL,
  `ContactEmail` varchar(256) NOT NULL,
  `Strikes` int(11) NOT NULL,
  `Balance` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`BuyerId`),
  KEY `FK_Buyers_Accounts` (`AccountId`),
  KEY `ApprovedBy` (`ApprovedBy`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `buyers`
--

INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(3, 7, 1, 'Egypt', 'Kotp@gamil.com', 0, 2200);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(4, 20, 1, 'Egypt', 'medoking91@gmail.com', 0, 2500);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(5, 24, 1, 'Egypt', 'testing1@testing.com', 2, 18877);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(6, 25, 1, 'Egypt', 'a@1255.com', 0, 63221);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(7, 26, 1, 'Algeria', 'rand@rand.org', 1, 7752);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(8, 27, 1, 'Bangladesh', 'rand2@rand.org', 0, 300);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(9, 29, 1, 'Egypt', 'medoking91@gmail.com', 0, 9398);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(10, 34, 1, 'United States of America', 'joshuah_rolfs@yahoo.com', 0, 26266);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(11, 35, 3, 'United States of America', 'cathy_prosac@gmail.com', 0, 0);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(12, 36, 1, 'Palestine', 'billie1998@gmail.com', 3, 1676);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(13, 37, 5, 'Azerbaijan', 'nico_satterfie@yahoo.com', 0, 2000);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(14, 41, 5, 'United States of America', 'elijah.maye@hotmail.com', 0, 6010);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(15, 42, 2, 'Canada', 'ally_wisok10@yahoo.com', 0, 22920);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(16, 43, 1, 'France', 'aaron1979@hotmail.com', 0, 8800);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(17, 48, NULL, 'Zimbabwe', 'a@12.com', 0, 0);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(18, 49, NULL, 'Zambia', 'a@12.com', 0, 0);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(19, 50, NULL, 'Yemen', 'a@12.com', 0, 0);
INSERT INTO `buyers` (`BuyerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(20, 51, NULL, 'Uraguay', 'a@12.com', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `games`
--

DROP TABLE IF EXISTS `games`;
CREATE TABLE IF NOT EXISTS `games` (
  `GameId` int(11) NOT NULL AUTO_INCREMENT,
  `SellerId` int(11) NOT NULL,
  `FirstOwner` int(11) DEFAULT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 NOT NULL,
  `Description` varchar(250) CHARACTER SET utf8mb4 NOT NULL,
  `ReleaseDate` date NOT NULL,
  `Price` double NOT NULL,
  `Version` varchar(10) NOT NULL,
  `Type` varchar(50) NOT NULL,
  `Sale` double NOT NULL,
  PRIMARY KEY (`GameId`),
  KEY `FK_Games_Buyers` (`FirstOwner`),
  KEY `FK_Games_Sellers` (`SellerId`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `games`
--

INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(10, 2, NULL, 'Second Game Edited', 'Second Game Second Game Second Game\r\nSecond Game Second Game Second Game', '2000-11-11', 750, '1.1.0', 'Adventure', 25);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(12, 2, 7, 'Minecraft', 'Minecraft is a sandbox video game developed by the Swedish video game developer Mojang Studios. The game was created by Markus \"Notch\" Persson in the Java programming language.', '2022-01-05', 260, '1.8', 'Open World', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(13, 2, 8, 'GTA 5', 'Grand Theft Auto V is a 2013 action-adventure game developed by Rockstar North and published by Rockstar Games. It is the seventh main entry in the Grand Theft Auto series,', '2022-01-06', 100, '1', 'Open World', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(15, 2, 6, 'XTrivia', 'Are you smarter than the average BuzzFeeder? I bet you are. Find out with our endless trivia quizzes.', '2022-01-07', 1200, '1', 'Strategy', 14);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(20, 14, 9, 'Fortnite', 'Fortnite is a free-to-play Battle Royale game with numerous game modes for every type of game player. Watch a concert, build an island or fight.', '2022-01-01', 1100, '1', 'Shooter', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(21, 15, NULL, 'The Legend of Zelda: Ocarina of Time', 'As a young boy, Link is tricked by Ganondorf, the King of the Gerudo Thieves. The evil human uses Link to gain access to the Sacred Realm, where he places his tainted hands on Triforce and transforms the beautiful Hyrulean landscape.', '2022-01-09', 1500, '1', 'Adventure', 12);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(22, 15, NULL, 'Super Mario', 'A plumber named Mario and his brother Luigi travel through the Mushroom Kingdom to save the princess from the evil Bowser. ... But one day, evil cast a shadow over the land and the evil King Bowser Koopa emerged with his army of Goombas.', '2022-01-09', 1000, '1', 'Adventure', 13);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(23, 15, NULL, 'Among Us', 'Among Us is a 2018 online multiplayer social deduction game developed and published by American game studio Innersloth. The game was inspired by the party game Mafia and the science fiction horror film The Thing.', '2022-01-09', 1200, '1', 'Strategy', 90);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(24, 15, 12, 'God of War', 'God of War is an action-adventure game developed by Santa Monica Studio and published by Sony Interactive Entertainment. It was released worldwide on April 20, 2018', '2022-01-09', 5000, '3', 'Adventure', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(25, 15, NULL, 'Death Stranding', 'Death Stranding is a 2019 action game developed by Kojima Productions. It is the first game from director Hideo Kojima and a Kojima Productions reborn as independent developer after Kojima\'s split from Konami in 2015', '2022-01-09', 6000, '1', 'Adventure', 50);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(26, 16, NULL, 'Call Of Duty', 'Call of Duty is a first-person shooter video game franchise published by Activision.', '2022-01-09', 500, '1', 'Shooter', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(27, 16, NULL, 'Assassin\'s Creed 3', 'Assassin\'s Creed III is a 2012 action-adventure video game developed by Ubisoft Montreal and published by Ubisoft for PlayStation 3, Xbox 360, Wii U, and Microsoft Windows.', '2022-01-09', 200, '1', 'Adventure', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(28, 17, NULL, 'squid game', 'korean game', '2022-01-09', 500, '2', 'Adventure', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(29, 17, NULL, 'Micky', 'Micky is interactive drama horror video game developed by Supermassive Games and published by Sony Computer Entertainment ', '2022-01-09', 200, '2', 'Action', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(30, 17, NULL, '8086 game', 'Intel Corporation is an American multinational corporation and technology company headquartered in Santa Clara, California. It is the world\'s largest semiconductor chip manufacturer by revenue.', '2022-01-09', 500, '1', 'Strategy', 0);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(31, 2, NULL, 'Cyberpunk 2077', 'Cyberpunk 2077 is an action role-playing video game developed and published by CD Projekt. The story takes place in Night City, an open world set in the Cyberpunk universe.', '2022-01-09', 1000, '1', 'Adventure', 1);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(32, 18, NULL, 'Red Dead Redemption 2', 'Red Dead Redemption 2 is a 2018 action-adventure game developed and published by Rockstar Games. The game is the third entry in the Red Dead series and is a prequel to the 2010 game Red Dead Redemption', '2018-10-05', 1000, '1.0.0', 'RD2', 20);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(33, 19, NULL, 'Rise of the Tomb Raider', 'Rise of the Tomb Raider is a 2015 action-adventure video game developed by Crystal Dynamics and published by Microsoft Studios and Square Enix\'s European subsidiary. ', '1998-06-15', 2500, '1.0.0', 'Adventure', 25);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(34, 19, NULL, 'Shadow of the Tomb Raider', 'Shadow of the Tomb Raider is a 2018 action-adventure video game developed by Eidos-Montréal and published by Square Enix\'s European subsidiary', '2000-05-15', 2600, '2.0.0', 'Action', 20);
INSERT INTO `games` (`GameId`, `SellerId`, `FirstOwner`, `Name`, `Description`, `ReleaseDate`, `Price`, `Version`, `Type`, `Sale`) VALUES(35, 18, NULL, 'Max Payne 3', 'Max Payne 3 is a third-person shooter video game developed by Rockstar Studios and published by Rockstar Games', '1999-06-23', 100, '2.0.0', 'Strategy', 10);

-- --------------------------------------------------------

--
-- Stand-in structure for view `games_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `games_details`;
CREATE TABLE IF NOT EXISTS `games_details` (
`OperatingSystem` varchar(50)
,`MinimumCPU` varchar(50)
,`RecommendedCPU` varchar(50)
,`MinimumGPU` varchar(50)
,`MinimumRam` int(11)
,`RecommendedRam` int(11)
,`RecommendedGPU` varchar(50)
,`Storage` int(11)
,`Sale` double
,`Type` varchar(50)
,`Version` varchar(10)
,`Price` double
,`ReleaseDate` date
,`Description` varchar(250)
,`Name` varchar(100)
,`FirstOwner` int(11)
,`SellerId` int(11)
,`GameId` int(11)
,`FirstOwnerName` varchar(302)
,`SellerName` varchar(302)
,`RatingCount` bigint(21)
,`NumberOfOrders` bigint(21)
,`Rating` double
,`LastOrderDate` datetime(6)
,`CanBeBought` int(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `games_reviews_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `games_reviews_details`;
CREATE TABLE IF NOT EXISTS `games_reviews_details` (
`GameId` int(11)
,`Name` varchar(100)
,`BuyerId` int(11)
,`BuyerUserName` varchar(50)
,`Rating` double
,`Text` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `moderators`
--

DROP TABLE IF EXISTS `moderators`;
CREATE TABLE IF NOT EXISTS `moderators` (
  `ModeratorId` int(11) NOT NULL AUTO_INCREMENT,
  `AccountId` int(11) NOT NULL,
  `AddedById` int(11) DEFAULT NULL,
  PRIMARY KEY (`ModeratorId`),
  KEY `FK_Moderators_Admins` (`AddedById`),
  KEY `FK_Moderators_Moderators` (`AccountId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `moderators`
--

INSERT INTO `moderators` (`ModeratorId`, `AccountId`, `AddedById`) VALUES(1, 22, 1);
INSERT INTO `moderators` (`ModeratorId`, `AccountId`, `AddedById`) VALUES(2, 23, 1);
INSERT INTO `moderators` (`ModeratorId`, `AccountId`, `AddedById`) VALUES(3, 28, 1);
INSERT INTO `moderators` (`ModeratorId`, `AccountId`, `AddedById`) VALUES(4, 30, 1);
INSERT INTO `moderators` (`ModeratorId`, `AccountId`, `AddedById`) VALUES(5, 45, 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `BuyerId` int(11) NOT NULL,
  `GameId` int(11) NOT NULL,
  `Date` datetime(6) NOT NULL,
  `PaidAmount` double NOT NULL,
  PRIMARY KEY (`BuyerId`,`GameId`),
  KEY `FK_Orders_Games` (`GameId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(5, 10, '2021-12-31 08:30:47.000000', 562);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(5, 12, '2022-01-08 10:08:22.000000', 260);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(5, 13, '2022-01-08 10:15:43.000000', 100);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(5, 32, '2022-02-09 13:45:35.000000', 800);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(6, 10, '2022-01-07 17:28:12.000000', 562);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(6, 12, '2022-01-07 17:29:40.000000', 260);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(6, 13, '2022-01-07 17:28:44.000000', 100);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(6, 15, '2022-01-07 13:54:46.000000', 2003);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(7, 12, '2022-01-06 07:51:54.000000', 700);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(8, 13, '2022-01-06 15:28:53.000000', 5000);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(9, 12, '2022-01-07 15:47:11.000000', 260);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(9, 20, '2022-01-08 13:50:40.000000', 20222);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(9, 23, '2022-01-09 16:01:46.000000', 120);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(10, 32, '2022-01-09 16:50:05.000000', 19000);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(12, 24, '2022-01-09 14:15:26.000000', 10000);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(14, 25, '2022-01-09 17:17:24.000000', 3000);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(14, 31, '2022-01-09 17:19:20.000000', 990);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(15, 32, '2022-01-09 16:41:04.000000', 19000);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(15, 34, '2022-01-09 16:41:34.000000', 2080);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(16, 26, '2022-01-09 16:43:52.000000', 500);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(16, 28, '2022-01-09 16:43:49.000000', 500);
INSERT INTO `orders` (`BuyerId`, `GameId`, `Date`, `PaidAmount`) VALUES(16, 29, '2022-01-09 16:43:55.000000', 200);

-- --------------------------------------------------------

--
-- Table structure for table `requirements`
--

DROP TABLE IF EXISTS `requirements`;
CREATE TABLE IF NOT EXISTS `requirements` (
  `GameId` int(11) NOT NULL,
  `OperatingSystem` varchar(50) NOT NULL,
  `MinimumCPU` varchar(50) NOT NULL,
  `RecommendedCPU` varchar(50) DEFAULT NULL,
  `MinimumGPU` varchar(50) NOT NULL,
  `RecommendedGPU` varchar(50) DEFAULT NULL,
  `MinimumRam` int(11) NOT NULL,
  `RecommendedRam` int(11) DEFAULT NULL,
  `Storage` int(11) NOT NULL,
  PRIMARY KEY (`GameId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `requirements`
--

INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(10, 'win 7', 'intel i5-4570', 'intel i5-10400', 'GTX 750-ti', 'GTX 1060-3gb', 2, 4, 25);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(12, 'win xp', 'core 2 due', 'i7', 'none', 'gtx 1660ti', 2, 16, 4);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(20, 'win 10', 'i3', 'i7', 'gtx 750', 'rtx 2060', 4, 16, 12);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(21, 'win 10', 'i3', 'i7', 'gtx 750', 'rtx 2060', 1, 4, 12);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(26, 'win 7', 'RTX 3090', 'intel core i9', 'rtx2070', 'rtx3090', 16, 32, 10000);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(32, 'win 10', 'intel i5-4570', 'intel i5-10400', 'GTX 750ti', 'GTX 1060 6gb', 6, 16, 50);
INSERT INTO `requirements` (`GameId`, `OperatingSystem`, `MinimumCPU`, `RecommendedCPU`, `MinimumGPU`, `RecommendedGPU`, `MinimumRam`, `RecommendedRam`, `Storage`) VALUES(33, 'win 10', 'intel i5-10400f', 'intel i7-10400f', 'GTX 750-ti', 'GTX 1080', 8, 16, 100);

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `GameId` int(11) NOT NULL,
  `BuyerId` int(11) NOT NULL,
  `Text` varchar(100) CHARACTER SET utf8mb4 NOT NULL,
  `Rating` double NOT NULL,
  PRIMARY KEY (`GameId`,`BuyerId`),
  KEY `FK_Reviews_Buyers` (`BuyerId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(10, 5, 'Very Good Game , I Highly Recommend It to Others', 7.5);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(10, 9, 'Wonderful Game used to play it till dawn', 8);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(12, 5, 'Beautiful Game made my childhood ', 10);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(12, 7, 'Wonderful Game used to play it till dawn', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(12, 9, 'The Greatest open world game of all time', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(13, 5, 'The Greatest open world game of all time', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(20, 9, 'The Greatest shooter game of all time', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(21, 13, 'Don\'t Know this Game but have nice reviews online', 6);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(22, 12, 'MarAu Game of the Year :D', 9.9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(22, 14, 'Very Good Game , I Highly Recommend It to Others', 8.75);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(23, 9, 'Best Multiplier Game for 2021', 7);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(23, 12, 'This Game is Kinda Sus', 6.9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(24, 9, 'One of  The Greatest open world game of all time', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(24, 12, 'Beautiful Game !', 8);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(25, 14, 'Good Game , I Highly Recommend It to Others', 9);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(26, 16, 'Very Good Game , I Highly Recommend It', 10);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(29, 16, 'Very Good Game , I Highly Recommend It to Others', 8);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(30, 9, '2 player Game made us cry', 8);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(31, 10, 'This Game doesn\'t have any bugs', 10);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(32, 5, 'The Greatest open world game of all time', 10);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(32, 14, 'Very Good Game , I Highly Recommend It to Others', 9.8);
INSERT INTO `reviews` (`GameId`, `BuyerId`, `Text`, `Rating`) VALUES(34, 15, 'Very Good Game , I Highly Recommend It to Others', 6.5);

-- --------------------------------------------------------

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
CREATE TABLE IF NOT EXISTS `sellers` (
  `SellerId` int(11) NOT NULL AUTO_INCREMENT,
  `AccountId` int(11) NOT NULL,
  `ApprovedBy` int(11) DEFAULT NULL,
  `Country` varchar(100) NOT NULL,
  `ContactEmail` varchar(256) NOT NULL,
  `Strikes` int(11) NOT NULL,
  `Balance` int(11) NOT NULL,
  PRIMARY KEY (`SellerId`),
  KEY `FK_Sellers_Accounts` (`AccountId`),
  KEY `ApprovedBy` (`ApprovedBy`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sellers`
--

INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(2, 9, 1, 'Bangladesh', 'Kotp911@gmail.com', 0, 1350);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(4, 11, 1, 'Egypt', 'medoking911@gmail.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(5, 12, 5, 'Egypt', '2021-11-28', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(6, 13, 1, 'Egypt', 'lol@gmail.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(7, 14, 5, 'Mozambique', 'testcontact@test.com', 1, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(8, 15, 1, 'Egypt', 'a@120.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(9, 16, 5, 'Egypt', 'a@1255.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(10, 17, 1, 'Egypt', 'a@1255.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(11, 18, 1, 'Egypt', 'a@1255.com', 0, 0);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(13, 31, 1, 'Egypt', 'a@1255.com', 4, 1000);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(14, 33, 3, 'Egypt', 'medoking91@gmail.com', 0, 20222);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(15, 38, 3, 'United States of America', 'ariel.schuli@gmail.com', 0, 13120);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(16, 39, 4, 'Egypt', 'a@1255.com', 0, 500);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(17, 40, 4, 'Egypt', 'a@1255.com', 0, 700);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(18, 44, 5, 'United States of America', 'Admin@Rockstar.com', 0, 38800);
INSERT INTO `sellers` (`SellerId`, `AccountId`, `ApprovedBy`, `Country`, `ContactEmail`, `Strikes`, `Balance`) VALUES(19, 46, 1, 'Egypt', 'admin@CrystalDynamics.com', 0, 2080);

-- --------------------------------------------------------

--
-- Stand-in structure for view `sellers_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `sellers_details`;
CREATE TABLE IF NOT EXISTS `sellers_details` (
`SellerId` int(11)
,`AccountId` int(11)
,`SellerName` varchar(100)
,`Country` varchar(100)
,`ContactEmail` varchar(256)
,`Strikes` int(11)
,`Balance` int(11)
,`GamesCount` bigint(21)
,`AvgGamesRating` double
);

-- --------------------------------------------------------

--
-- Structure for view `account_info`
--
DROP TABLE IF EXISTS `account_info`;

DROP VIEW IF EXISTS `account_info`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `account_info`  AS  select 'Buyer' AS `AccountType`,`a`.`AccountId` AS `AccountId`,`a`.`Username` AS `Username`,`a`.`fName` AS `fName`,`a`.`mName` AS `mName`,`a`.`lName` AS `lName`,`a`.`PasswordHash` AS `PasswordHash`,`a`.`EmailAddress` AS `EmailAddress`,`a`.`Gender` AS `Gender`,`a`.`BirthDate` AS `BirthDate`,`a`.`Status` AS `Status`,`b`.`Country` AS `Country`,`b`.`ContactEmail` AS `ContactEmail`,`b`.`Strikes` AS `Strikes`,`b`.`Balance` AS `Balance`,`b`.`BuyerId` AS `ID` from (`accounts` `a` join `buyers` `b`) where (`a`.`AccountId` = `b`.`AccountId`) union select 'Seller' AS `AccountType`,`a`.`AccountId` AS `AccountId`,`a`.`Username` AS `Username`,`a`.`fName` AS `fName`,`a`.`mName` AS `mName`,`a`.`lName` AS `lName`,`a`.`PasswordHash` AS `PasswordHash`,`a`.`EmailAddress` AS `EmailAddress`,`a`.`Gender` AS `Gender`,`a`.`BirthDate` AS `BirthDate`,`a`.`Status` AS `Status`,`s`.`Country` AS `Country`,`s`.`ContactEmail` AS `ContactEmail`,`s`.`Strikes` AS `Strikes`,`s`.`Balance` AS `Balance`,`s`.`SellerId` AS `ID` from (`accounts` `a` join `sellers` `s`) where (`a`.`AccountId` = `s`.`AccountId`) union select 'Admin' AS `AccountType`,`a`.`AccountId` AS `AccountId`,`a`.`Username` AS `Username`,`a`.`fName` AS `fName`,`a`.`mName` AS `mName`,`a`.`lName` AS `lName`,`a`.`PasswordHash` AS `PasswordHash`,`a`.`EmailAddress` AS `EmailAddress`,`a`.`Gender` AS `Gender`,`a`.`BirthDate` AS `BirthDate`,`a`.`Status` AS `Status`,'' AS `Country`,'' AS `ContactEmail`,0 AS `Strikes`,0 AS `Balance`,`s`.`AdminId` AS `ID` from (`accounts` `a` join `admins` `s`) where (`a`.`AccountId` = `s`.`AccountId`) union select 'Moderator' AS `AccountType`,`a`.`AccountId` AS `AccountId`,`a`.`Username` AS `Username`,`a`.`fName` AS `fName`,`a`.`mName` AS `mName`,`a`.`lName` AS `lName`,`a`.`PasswordHash` AS `PasswordHash`,`a`.`EmailAddress` AS `EmailAddress`,`a`.`Gender` AS `Gender`,`a`.`BirthDate` AS `BirthDate`,`a`.`Status` AS `Status`,'' AS `Country`,'' AS `ContactEmail`,0 AS `Strikes`,0 AS `Balance`,`s`.`ModeratorId` AS `ID` from (`accounts` `a` join `moderators` `s`) where (`a`.`AccountId` = `s`.`AccountId`) ;

-- --------------------------------------------------------

--
-- Structure for view `all_orders`
--
DROP TABLE IF EXISTS `all_orders`;

DROP VIEW IF EXISTS `all_orders`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `all_orders`  AS  select `o`.`Date` AS `OrderDate`,(select `account_info`.`Username` from `account_info` where (`account_info`.`AccountId` = `b`.`AccountId`)) AS `Buyer`,(select `account_info`.`Username` from `account_info` where (`account_info`.`AccountId` = `s`.`AccountId`)) AS `Seller`,`g`.`Name` AS `Game`,`o`.`PaidAmount` AS `PaidAmount` from (((`orders` `o` join `games` `g`) join `sellers` `s`) join `buyers` `b`) where ((`o`.`GameId` = `g`.`GameId`) and (`g`.`SellerId` = `s`.`SellerId`) and (`o`.`BuyerId` = `b`.`BuyerId`)) ;

-- --------------------------------------------------------

--
-- Structure for view `auction_details`
--
DROP TABLE IF EXISTS `auction_details`;

DROP VIEW IF EXISTS `auction_details`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `auction_details`  AS  select `auctions`.`AuctionId` AS `AuctionId`,`auctions`.`StartDate` AS `StartDate`,`auctions`.`EndDate` AS `EndDate`,(select if((now() < `auctions`.`StartDate`),0,if((now() >= `auctions`.`EndDate`),if((`games`.`FirstOwner` is not null),-(2),-(1)),1))) AS `Status`,`games`.`GameId` AS `GameId`,`games`.`Name` AS `GameName`,`games`.`Description` AS `GameDescription`,`auctions`.`HighestBidId` AS `HighestBidId`,`buyers`.`BuyerId` AS `HighestBidBuyerId`,ifnull(`bids`.`BidAmount`,0) AS `HighestBidAmount`,`accounts`.`Username` AS `HighestBidBuyerUserName`,`bids`.`Date` AS `HighestBidDate` from ((((`auctions` left join `bids` on((`auctions`.`HighestBidId` = `bids`.`BidId`))) left join `buyers` on((`bids`.`BuyerId` = `buyers`.`BuyerId`))) left join `accounts` on((`buyers`.`AccountId` = `accounts`.`AccountId`))) left join `games` on((`auctions`.`GameId` = `games`.`GameId`))) order by (select if((now() < `auctions`.`StartDate`),0,if((now() >= `auctions`.`EndDate`),if((`games`.`FirstOwner` is not null),-(2),-(1)),1))) desc ;

-- --------------------------------------------------------

--
-- Structure for view `games_details`
--
DROP TABLE IF EXISTS `games_details`;

DROP VIEW IF EXISTS `games_details`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `games_details`  AS  select `requirements`.`OperatingSystem` AS `OperatingSystem`,`requirements`.`MinimumCPU` AS `MinimumCPU`,`requirements`.`RecommendedCPU` AS `RecommendedCPU`,`requirements`.`MinimumGPU` AS `MinimumGPU`,`requirements`.`MinimumRam` AS `MinimumRam`,`requirements`.`RecommendedRam` AS `RecommendedRam`,`requirements`.`RecommendedGPU` AS `RecommendedGPU`,`requirements`.`Storage` AS `Storage`,`games`.`Sale` AS `Sale`,`games`.`Type` AS `Type`,`games`.`Version` AS `Version`,`games`.`Price` AS `Price`,`games`.`ReleaseDate` AS `ReleaseDate`,`games`.`Description` AS `Description`,`games`.`Name` AS `Name`,`games`.`FirstOwner` AS `FirstOwner`,`games`.`SellerId` AS `SellerId`,`games`.`GameId` AS `GameId`,concat(`accounts`.`fName`,' ',convert(`accounts`.`mName` using utf8mb4),' ',convert(`accounts`.`lName` using utf8mb4)) AS `FirstOwnerName`,concat(`accounts_1`.`fName`,' ',convert(`accounts_1`.`mName` using utf8mb4),' ',convert(`accounts_1`.`lName` using utf8mb4)) AS `SellerName`,(select count(1) AS `Expr1` from `reviews` `r` where (`r`.`GameId` = `games`.`GameId`)) AS `RatingCount`,(select count(1) AS `Expr1` from `orders` where (`orders`.`GameId` = `games`.`GameId`)) AS `NumberOfOrders`,(select avg(`r`.`Rating`) AS `Expr1` from `reviews` `r` where (`r`.`GameId` = `games`.`GameId`)) AS `Rating`,(select `orders_1`.`Date` from `orders` `orders_1` where (`orders_1`.`GameId` = `games`.`GameId`) order by `orders_1`.`Date` desc limit 1) AS `LastOrderDate`,(select (now() > `auctions`.`EndDate`) from `auctions` where (`auctions`.`GameId` = `games`.`GameId`)) AS `CanBeBought` from (((((`games` left join `requirements` on((`games`.`GameId` = `requirements`.`GameId`))) left join `buyers` on((`games`.`FirstOwner` = `buyers`.`BuyerId`))) left join `sellers` on((`games`.`SellerId` = `sellers`.`SellerId`))) left join `accounts` on((`buyers`.`AccountId` = `accounts`.`AccountId`))) left join `accounts` `accounts_1` on((`sellers`.`AccountId` = `accounts_1`.`AccountId`))) ;

-- --------------------------------------------------------

--
-- Structure for view `games_reviews_details`
--
DROP TABLE IF EXISTS `games_reviews_details`;

DROP VIEW IF EXISTS `games_reviews_details`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `games_reviews_details`  AS  select `g`.`GameId` AS `GameId`,`g`.`Name` AS `Name`,`r`.`BuyerId` AS `BuyerId`,`a`.`Username` AS `BuyerUserName`,`r`.`Rating` AS `Rating`,`r`.`Text` AS `Text` from ((`games` `g` join `reviews` `r` on((`g`.`GameId` = `r`.`GameId`))) join `account_info` `a` on(((`a`.`ID` = `r`.`BuyerId`) and (`a`.`AccountType` = 'Buyer')))) ;

-- --------------------------------------------------------

--
-- Structure for view `sellers_details`
--
DROP TABLE IF EXISTS `sellers_details`;

DROP VIEW IF EXISTS `sellers_details`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `sellers_details`  AS  select `sellers`.`SellerId` AS `SellerId`,`sellers`.`AccountId` AS `AccountId`,`accounts`.`fName` AS `SellerName`,`sellers`.`Country` AS `Country`,`sellers`.`ContactEmail` AS `ContactEmail`,`sellers`.`Strikes` AS `Strikes`,`sellers`.`Balance` AS `Balance`,(select count(1) AS `Expr1` from `games` where (`sellers`.`SellerId` = `games`.`SellerId`)) AS `GamesCount`,(select coalesce(avg(`joinedtable`.`GameRating`),0) from (((select `games`.`GameId` AS `GameRatingID`,avg(`reviews`.`Rating`) AS `GameRating` from (`games` join `reviews` on((`reviews`.`GameId` = `games`.`GameId`))) group by `games`.`GameId`)) `joinedtable` join `games` on((`joinedtable`.`GameRatingID` = `games`.`GameId`))) where (`games`.`SellerId` = `sellers`.`SellerId`)) AS `AvgGamesRating` from (`sellers` join `accounts` on((`sellers`.`AccountId` = `accounts`.`AccountId`))) ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `auctions`
--
ALTER TABLE `auctions`
  ADD CONSTRAINT `auctions_ibfk_1` FOREIGN KEY (`GameId`) REFERENCES `games` (`GameId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `auctions_ibfk_2` FOREIGN KEY (`HighestBidId`) REFERENCES `bids` (`BidId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `bids`
--
ALTER TABLE `bids`
  ADD CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`AuctionId`) REFERENCES `auctions` (`AuctionId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`BuyerId`) REFERENCES `buyers` (`BuyerId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `buyers`
--
ALTER TABLE `buyers`
  ADD CONSTRAINT `buyers_ibfk_1` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `buyers_ibfk_2` FOREIGN KEY (`ApprovedBy`) REFERENCES `moderators` (`ModeratorId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `games`
--
ALTER TABLE `games`
  ADD CONSTRAINT `games_ibfk_1` FOREIGN KEY (`SellerId`) REFERENCES `sellers` (`SellerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `games_ibfk_2` FOREIGN KEY (`FirstOwner`) REFERENCES `buyers` (`BuyerId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `moderators`
--
ALTER TABLE `moderators`
  ADD CONSTRAINT `moderators_ibfk_1` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `moderators_ibfk_2` FOREIGN KEY (`AddedById`) REFERENCES `admins` (`AdminId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`BuyerId`) REFERENCES `buyers` (`BuyerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`GameId`) REFERENCES `games` (`GameId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `requirements`
--
ALTER TABLE `requirements`
  ADD CONSTRAINT `requirements_ibfk_1` FOREIGN KEY (`GameId`) REFERENCES `games` (`GameId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`GameId`) REFERENCES `games` (`GameId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`BuyerId`) REFERENCES `buyers` (`BuyerId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sellers`
--
ALTER TABLE `sellers`
  ADD CONSTRAINT `sellers_ibfk_1` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sellers_ibfk_2` FOREIGN KEY (`ApprovedBy`) REFERENCES `moderators` (`ModeratorId`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
