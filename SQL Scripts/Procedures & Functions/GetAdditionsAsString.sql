-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	Additions in this format "Amount:AdditionName:price,Amount:AdditionName:price"
-- =============================================
CREATE OR ALTER FUNCTION GetAdditionsAsString
(
	-- Add the parameters for the function here
	@ordernumber INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @str_additions VARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SELECT @str_additions = STRING_AGG(CONCAT(ra.amount, ':', ra.additionname, ':', ads.price), ',')
	FROM Reservation r
	JOIN ReservationAddition ra
		ON r.ordernumber = ra.ordernumber
	JOIN AdditionsSeason ads
		ON ra.additionname = ads.additionname
	WHERE r.ordernumber = @ordernumber AND ads.seasonname = dbo.GetSeasonName(r.startdate, r.enddate)
	GROUP BY r.ordernumber

	-- Return the result of the function
	RETURN @str_additions
END
GO

