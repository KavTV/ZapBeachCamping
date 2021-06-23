USE [ZAP_Base]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSeasonName]    Script Date: 14/06/2021 13.05.53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: 10-06-2021
-- Description:	Function to return season name
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[GetSeasonName] 
(
	-- Add the parameters for the function here
	@start DATE,
	@end DATE
)
RETURNS VARCHAR(40)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @seasonName VARCHAR(40)

	-- Add the T-SQL statements to compute the return value here
	
	SELECT TOP(1) @seasonName = SeasonName
	FROM SeasonPeriods
	WHERE (FORMAT(@start, 'Md') = FORMAT([from], 'Md') and FORMAT(@end, 'Md') = FORMAT([to], 'Md')) OR
		(SeasonName NOT IN (
			'Forår'
			,'Vinter'
			,'Efterår'
			,'Sommer'
			,'Special')
			AND ((FORMAT(@start, 'Md') >= FORMAT([from], 'Md') AND FORMAT(@start, 'Md') < FORMAT([to], 'Md'))
				OR (FORMAT(@end, 'Md')>= FORMAT([from], 'Md') and FORMAT(@end, 'Md') <= FORMAT([to], 'Md'))))
	ORDER BY 
		CASE
			WHEN @start < [from] THEN DATEDIFF(DAY, [from], @end)
			ELSE DATEDIFF(DAY, @start, [to]) 
		END DESC
		
	-- Return the result of the function
	RETURN ISNULL(@seasonName,'Lavsæson') --If nothing match then its lavsæson

END
