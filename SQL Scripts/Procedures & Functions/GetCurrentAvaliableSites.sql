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
-- Description:	When execute the procedure do it like this:
-- SELECT dbo.GetCurrentAvaliableSites(DEFAULT) 
-- The default value is need to specified to retrieve the value
-- =============================================
CREATE OR ALTER FUNCTION GetCurrentAvaliableSites()
RETURNS TABLE 
AS
RETURN 
(
	SELECT cs.id
		, CASE
			WHEN ordernumber IS NULL 
			THEN 'TRUE'
			ELSE 'FALSE'
		END AS [Value]
	FROM CampingSite cs
	LEFT JOIN Reservation r
		ON cs.id = r.campingid
		AND (( (FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND FORMAT(GETDATE(), 'yyyy-MM-dd') > R.startdate)
				OR (FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND checkin = 1)
			   )
			OR (r.enddate = FORMAT(GETDATE(), 'yyyy-MM-dd') AND r.checkout != 1))
	WHERE cs.id IN ('73', '72', '70', '68', '67') --Linjen kan fjernes men er her da vi har valgt kun at tjekke følgende pladser
)
GO
