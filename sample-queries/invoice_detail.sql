DELIMITER //

CREATE PROCEDURE `invoice_detail`(invoiceid INT)
BEGIN
	SELECT a.invoice_id, a.occupied_id, d.property_id, d.occupant_id, a.invoice_name, CONCAT("#", a.invoice_number) invoice_number, a.invoice_type_id, c.invoice_type, a.due_date, a.sent_at, DATE_ADD(DATE(sent_at), INTERVAL 7 DAY) sent_overdue, b.invoice_status_id, b.invoice_status,
	a.subtotal, a.vat, a.total, a.email_text
	FROM invoices a
	JOIN status_invoice b ON a.invoice_status=b.invoice_status_id
	JOIN invoice_type c ON a.invoice_type_id=c.invoice_type_id
	JOIN occupied_property d ON a.occupied_id=d.occupied_id
	WHERE a.invoice_id=invoiceid;
END //

DELIMITER ;