SELECT cs.id
		, CASE
			WHEN ordernumber IS NULL 
			THEN 'TRUE'
			ELSE CASE 
				WHEN r.enddate = FORMAT(GETDATE(), 'yyyy-MM-dd') AND r.checkout = 0 THEN 'OPS'
				WHEN r.checkout = 1 THEN 'TRUE'
				WHEN  FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND checkin = 0 THEN 'OPS'
				ELSE 'FALSE'
				END
		END AS [Value]
	FROM CampingSite cs
	LEFT JOIN Reservation r
		ON cs.id = r.campingid
		AND (( (FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND FORMAT(GETDATE(), 'yyyy-MM-dd') > R.startdate)
				OR (FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate)
				--OR (FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND checkin = 1)
			   )
			OR (r.enddate = FORMAT(GETDATE(), 'yyyy-MM-dd') AND r.checkout != 1))
	WHERE cs.id IN ('73', '72', '70', '68', '67') --Linjen kan fjernes men er her da vi har valgt kun at tjekke følgende pladser