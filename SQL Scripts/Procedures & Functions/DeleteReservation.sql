CREATE OR ALTER PROCEDURE DeleteReservation @ordernumber INT
AS
DELETE FROM Reservation WHERE ordernumber = @ordernumber
;