------------- undelete_loan_statement ----------
create or replace function undelete_loan_statement(v_loan_statement_id uuid)
returns void as $$
declare 
	v_client_id uuid;
	v_loan_id uuid;
begin
	insert into log (origin, message) values ('undelete_loan_statement', 'start');

	-- Declare variables
	SELECT client_id, loan_id
	INTO v_client_id, v_loan_id
	FROM loan_statements
	WHERE id = v_loan_statement_id;

	-- Update
	UPDATE loan_statements
	SET delete_date = null, delete_reason = null, payment_status = 'unknown'
	WHERE id = v_loan_statement_id;


	-- Calculate values
	perform calculate_loan_statement_values(v_loan_statement_id);
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);


	insert into log (origin, message) values ('undelete_loan_statement', 'end');	

EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'undelete_loan_statement - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;