DELIMITER //

CREATE PROCEDURE `invoice_list`(occupiedid INT, statusid INT, sdateval DATE, edateval DATE, search VARCHAR(100))
BEGIN
	DECLARE wherestatus VARCHAR(250);
	DECLARE wheredate VARCHAR(250);
	DECLARE wheresearch VARCHAR(250);
	
	IF (statusid IS NOT NULL) THEN
		SET wherestatus = CONCAT(" and a.invoice_status=", statusid);
	ELSE
		SET wherestatus = "";
	END IF;
	
	IF (sdateval IS NOT NULL AND edateval IS NOT NULL) THEN
		SET wheredate = CONCAT(" AND ((a.due_date BETWEEN '", sdateval, "' AND '", edateval, "') or (DATE(a.created_at) BETWEEN '", sdateval, "' AND '", edateval, "'))");
	ELSE
		SET wheredate = "";
	END IF;
	
	IF (search IS NOT NULL) THEN
		SET wheresearch = CONCAT(" and (a.invoice_name LIKE '%", search, "%' OR c.invoice_type LIKE '%", search, "%')");
	ELSE
		SET wheresearch = "";
	END IF;
	
	SET @queryText = CONCAT("SELECT a.occupied_id, a.invoice_id, a.invoice_name, a.invoice_type_id, c.invoice_type, a.due_date, b.invoice_status_id, b.invoice_status, DATE(a.created_at) AS date_create
		FROM invoices a
		JOIN status_invoice b ON a.invoice_status=b.invoice_status_id
		JOIN invoice_type c ON a.invoice_type_id=c.invoice_type_id
		WHERE a.occupied_id=", occupiedid, wherestatus, wheredate, wheresearch, " ORDER BY a.created_at DESC"); -- FIELD(a.invoice_status, 4, 3, 2, 1, 5)
	PREPARE stmt FROM @queryText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END //

DELIMITER ;