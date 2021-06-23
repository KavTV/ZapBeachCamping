USE [ZAP_Base]
GO
/****** Object:  UserDefinedFunction [dbo].[IsReservationAdditionValid]    Script Date: 22/06/2021 15.00.59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
	Author:		Philip
	Create date: <Create Date, ,>
	Description:	Return 1 if it valid Check if reservation 
	ALTER TABLE ReservationAddition
	DROP [CHK_IsValid]

	ALTER TABLE ReservationAddition
	ADD CONSTRAINT CHK_IsValid CHECK(dbo.IsReservationAdditionValid(ordernumber, additionname) = 1)

   ============================================= */
ALTER   FUNCTION [dbo].[IsReservationAdditionValid]
(
	-- Add the parameters for the function here
	@ordernumber INT,
	@additionname VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @IsValid BIT
	SET @IsValid = 1

	-- Add the T-SQL statements to compute the return value here
	IF (@additionname = '1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen')
		BEGIN 
		IF NOT EXISTS (SELECT * FROM Reservation r JOIN CampingSiteTypes cst ON r.campingid = cst.campingid WHERE cst.typename = 'Lille campingplads' AND r.ordernumber = @ordernumber)
			SET @IsValid = 0
		END
	-- Return the result of the function
	RETURN @IsValid;

END
