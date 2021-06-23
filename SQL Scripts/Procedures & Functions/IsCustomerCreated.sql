-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Return true if there is a customer with the specified email
-- DECLARE @result BIT
-- EXECUTE @result = dbo.IsCustomerCreated 'test'
-- SELECT @result
-- In C# the result should be a bool
-- =============================================
CREATE OR ALTER PROCEDURE IsCustomerCreated
	-- Add the parameters for the stored procedure here
	@email VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM Customer WHERE email = @email)
		RETURN 1
	ELSE 
		RETURN 0
END
GO
