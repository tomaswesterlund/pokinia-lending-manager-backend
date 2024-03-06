------------- create_payment_for_zero_interest_loan ----------
create or replace function create_payment_for_zero_interest_loan(v_client_id UUID, v_loan_id UUID, v_principal_amount_paid float8, v_pay_date date, v_receipt_image_path text)
returns void as $$
declare 
	v_initial_principal_amount float8;
	v_expected_pay_date date;
	v_total_principal_amount_paid float8;
	v_remaining_principal_amount float8;
	v_payment_status text;
begin
	insert into log (origin, message) values ('create_payment_for_zero_interest_loan', 'start');

	-- Declare variables
	select initial_principal_amount, expected_pay_date 
	into v_initial_principal_amount, v_expected_pay_date
	from zero_interest_loans zil
	where loan_id = v_loan_id;
	
	-- Insert into payments
	insert into payments (client_id, loan_id, interest_amount_paid, principal_amount_paid, pay_date, receipt_image_path)
	values (v_client_id, v_loan_id, 0, v_principal_amount_paid, v_pay_date, v_receipt_image_path);

	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	insert into log (origin, message) values ('create_payment_for_zero_interest_loan', 'end');	

EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'create_payment_for_zero_interest_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
