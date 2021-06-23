USE [ZAP_Base]
GO
/****** Object:  UserDefinedFunction [dbo].[GetReservationTotalPrice]    Script Date: 14/06/2021 11.59.28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	=============================================
	Author:		Philip
	Create date: <Create Date, ,>
	Description:	Calculate reservation additions, campingsite additions and the campingsite price where every 4 day is free
	
	ALTER TABLE Reservation
	DROP COLUMN TotalPrice

	ALTER TABLE Reservation
	ADD TotalPrice AS ([dbo].[GetReservationTotalPrice]([campingid],[ordernumber],[typename],[startdate],[enddate]))
	
	============================================= */
CREATE OR ALTER FUNCTION [dbo].[GetReservationTotalPrice]
(
	-- Add the parameters for the function here
	@Campingid VARCHAR(3),
	@ordernumber INT,
	@typename VARCHAR(30),
	@startdate DATE,
	@enddate DATE
)
RETURNS NUMERIC(8,2)
AS
BEGIN
	--Implement isnull on every place where it set @Totalprice
	-- Calculate the days the customer should pay for
	DECLARE @DaysToPayForPlace INT
	SET @DaysToPayForPlace = DATEDIFF(DAY, @startdate, @enddate) - ROUND((DATEDIFF(DAY, @startdate, @enddate) / 4), 0, 0) -- Actual days minus the free days, ever 4 day is free, Always ROUND DOWN 
	
	-- Declare the return variable here
	DECLARE @TotalPrice NUMERIC(8,2)

	--First get Site addition price
	SELECT @TotalPrice = ISNULL(SUM(ca.price * DATEDIFF(DAY, @startdate, @enddate)), 0)
	FROM CampingSiteAdditions csa
	JOIN CampingAddition ca
		ON csa.additionname = ca.[name]
	WHERE csa.campingid = @Campingid

	-- if the reservation not containe a special season type like discount then it should calculate the sitetype price
	IF NOT EXISTS (SELECT * FROM ReservationAddition ra JOIN AdditionsSeason ads ON ra.additionname = ads.additionname WHERE ra.ordernumber = @ordernumber AND ads.seasonname = 'Special')
		BEGIN
			-- Set the totalprice from (site price * days)
			SELECT @TotalPrice = 
				CASE
					WHEN @typename IN ( 'Forår', 'Efterår', 'Sommer', 'Vinter')
						THEN @TotalPrice + ISNULL(ts.price, 0) --for season then it one time pay
					WHEN @Campingid IN ( 'H1', 'H2', 'H3', 'H4', 'H5', 'H7', 'H8', 'H10', 'H11', 'H12', 'H13', 'H14', 'H15')
						THEN @TotalPrice + ISNULL(ts.price, 0) * DATEDIFF(DAY, @startdate, @enddate) --For hytter everyday should be payed 
					ELSE 
						@TotalPrice + ISNULL((ts.price), 0) * @DaysToPayForPlace --every 4 day its its free 
				END
			FROM SeasonPeriods ps
			JOIN TypeSeason ts
				ON ts.seasonname = ps.SeasonName
			WHERE ts.typename = @typename
				AND ps.SeasonName = dbo.GetSeasonName(@startdate, @enddate)
		END

	--then get reservation additions price
	--Declare a table to insert price for each paytype in addition
	DECLARE @t TABLE(price NUMERIC(18,2))
	INSERT INTO @t
	SELECT CASE a.paytype
		WHEN 'OneTime'
			THEN ISNULL(SUM(ads.price * ra.amount), 0)
		WHEN 'Daily'
			THEN (ISNULL(SUM(ads.price * ra.amount), 0) * DATEDIFF(DAY, @startdate, @enddate))
		WHEN 'Daily-1'
			THEN (ISNULL(SUM(ads.price * ra.amount), 0) * (DATEDIFF(DAY, @startdate, @enddate)-1))
		END AS price
	FROM AdditionsSeason ads
	JOIN Additions a
		ON ads.additionname = a.[name]
	JOIN ReservationAddition ra
		ON ads.additionname = ra.additionname
	WHERE ra.ordernumber = @ordernumber 
		AND (ads.seasonname = dbo.GetSeasonName(@startdate, @enddate)
			OR ads.seasonname = 'Special' )
	GROUP BY a.paytype
	-- Return the result of the function
	--Set the totalprice to sum of the paytype prices
	SELECT @TotalPrice = @TotalPrice + ISNULL(SUM(price),0) FROM @t
	-- Return the result of the function
	RETURN @TotalPrice;

END
