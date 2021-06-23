-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
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
-- Create date: <Create Date,,>
-- Description:	Get reservation from ordernumber
-- =============================================
CREATE OR ALTER FUNCTION GetReservation
(	
	-- Add the parameters for the function here
	@ordernumber INT
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT r.ordernumber
		, r.email
		, r.campingid
		, r.typename
		, r.startdate
		, r.enddate
		, r.TotalPrice
		, dbo.GetAdditionsAsString(ordernumber) AS ReservationAdditions
	FROM Reservation r
	WHERE ordernumber = @ordernumber
)
GO
