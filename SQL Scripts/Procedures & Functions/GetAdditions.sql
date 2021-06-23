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
-- Description:	Get all additions the user can add to reservation 
-- =============================================
CREATE OR ALTER FUNCTION GetAdditions 
(	
	-- Add the parameters for the function here
	@startdato DATE
	,@enddate DATE
	, @typeName VARCHAR(30)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT a.[name]
		, ads.seasonname
		, ads.price
		, paytype
	FROM Additions a
	JOIN AdditionsSeason ads
		ON a.[name] = ads.additionname
	WHERE ads.seasonname = dbo.GetSeasonName(@startdato, @enddate)
		AND a.[name] != CASE WHEN @typeName  NOT LIKE '%hytte%' THEN 'Slutrengøring' ELSE '' END

)
GO
