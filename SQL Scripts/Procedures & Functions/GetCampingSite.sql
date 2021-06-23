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
-- Description:	Get the camping site customer have selected
-- =============================================
CREATE OR ALTER FUNCTION GetCampingSite
(	
	-- Add the parameters for the function here
	@CampingID VARCHAR(3),
	@typename VARCHAR(30),
	@StartDate DATE,
	@EndDate DATE
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT id AS CampingID
		, cst.typename
		, SitePrice
		, Campingadditions
	FROM dbo.GetAvaliableSites(@StartDate, @EndDate, @typename)
	JOIN CampingSiteTypes cst
		ON id = cst.campingid
	WHERE id = @CampingID AND cst.typename = @typename
)
GO
