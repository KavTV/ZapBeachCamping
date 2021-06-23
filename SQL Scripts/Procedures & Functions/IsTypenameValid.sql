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
-- Description:	Check if the camping site containe the specific typename
-- =============================================
CREATE OR ALTER FUNCTION IsTypenameValid 
(
	-- Add the parameters for the function here
	@typename VARCHAR(30),
	@campingid VARCHAR(3)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result BIT

	-- Add the T-SQL statements to compute the return value here
	IF EXISTS (SELECT * FROM CampingSiteTypes WHERE campingid = @campingid AND typename = @typename)
		SET @Result = 1;
		ELSE SET @Result = 0;
	
	-- Return the result of the function
	RETURN @Result

END
GO

