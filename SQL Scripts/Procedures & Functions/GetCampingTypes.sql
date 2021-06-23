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
-- Description:	Get all camping sites
-- CALL:
-- SELECT * FROM dbo.GetCampingTypes() ORDER BY [name] ASC
-- =============================================
CREATE OR ALTER FUNCTION GetCampingTypes(@IsSeasonType BIT, @IsSale BIT)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT DISTINCT ct.[name]
	FROM Campingtype ct
	JOIN TypeSeason ts
		ON ct.[name] = ts.typename
	WHERE (@IsSeasonType = 0 AND @IsSale = 0 AND ts.seasonname IN ('Højsæson', 'Lavsæson'))
		OR (@IsSeasonType = 1 AND ts.seasonname NOT IN ('Højsæson', 'Lavsæson'))
		OR (@IsSeasonType = 0 AND @IsSale = 1 AND ct.[name] IN ('Teltplads', 'Lille campingplads') AND ts.seasonname IN ('Højsæson', 'Lavsæson'))

)
GO