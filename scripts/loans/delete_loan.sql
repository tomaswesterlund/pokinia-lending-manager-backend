
------------- delete_loan ----------
create or replace function delete_loan(v_loan_id uuid, v_delete_date date, v_delete_reason text)
returns void as $$
declare
	v_client_id uuid;
begin
	insert into log (origin, message) values ('delete_loan', 'start');

	-- Declare variables
	SELECT client_id
	INTO v_client_id
	FROM loans
	WHERE id = v_loan_id;

	-- Update
	UPDATE loans
	SET delete_date = v_delete_date, delete_reason = v_delete_reason, payment_status = 'deleted'
	WHERE id = v_loan_id;


	-- Calculate values
	-- perform calculate_loan_statement_values(v_loan_statement_id);
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);


	insert into log (origin, message) values ('delete_loan', 'end');	

EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'delete_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;