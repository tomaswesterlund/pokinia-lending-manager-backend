

------------- create_payment_for_open_ended_loan ----------
create or replace function create_payment_for_open_ended_loan(v_client_id UUID, v_loan_id UUID, v_loan_statement_id UUID, v_interest_amount_paid float8, v_principal_amount_paid float8, v_pay_date date, v_receipt_image_path text)
returns void as $$
declare 
	v_total_interest_amount_paid float8;
	v_total_principal_amount_paid float8;
begin
	insert into log (origin, message) values ('create_payment_for_open_ended_loan', 'start');

	-- Insert payment 
	insert into payments (client_id, loan_id, loan_statement_id, interest_amount_paid, principal_amount_paid, pay_date, receipt_image_path)
	values (v_client_id, v_loan_id, v_loan_statement_id, v_interest_amount_paid, v_principal_amount_paid, v_pay_date, v_receipt_image_path);

	-- Calculate values
	perform calculate_loan_statement_values(v_loan_statement_id);
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	insert into log (origin, message) values ('create_payment_for_open_ended_loan', 'end');	
EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'create_payment_for_zero_interest_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
