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
-- Description:	Get sites and types and prices
-- SELECT * FROM dbo.GetAvaliableSites(sdato,edato, type) ORDER BY LEN(id), id
-- =============================================
CREATE OR ALTER FUNCTION GetAvaliableSites
(	
	-- Add the parameters for the function here
	@StartDate DATE,
	@EndDate DATE,
	@TypeName VARCHAR(30)
)
RETURNS TABLE 
AS
RETURN 
(

WITH tempreservation AS (
-- Get all camping id which have a reservation
	SELECT campingid
	FROM Reservation R
	WHERE NOT ( (@EndDate > R.enddate AND @StartDate > R.enddate)
				OR (@EndDate < R.startdate AND @StartDate <R.startdate)
			   )
)
	SELECT cs.id
		, SUM(ISNULL(ca.price,0)+ISNULL(ts.price,0)) AS SitePrice
		, STRING_AGG(ca.[name], ',') AS Campingadditions
	FROM CampingSite cs
	JOIN CampingSiteTypes cst
		ON cs.id = cst.campingid
	JOIN TypeSeason ts
		ON cst.typename = ts.typename
	LEFT JOIN CampingSiteAdditions csa
		ON cs.id = csa.campingid
	LEFT JOIN CampingAddition ca
		ON csa.additionname = ca.[name]
	WHERE ts.typename = CASE WHEN @TypeName IS NULL THEN ts.typename ELSE @TypeName END
		AND	cs.id NOT IN (SELECT campingid FROM tempreservation)
		AND ts.seasonname = dbo.GetSeasonName(@StartDate, @EndDate)
	GROUP BY cs.id
)
GO
