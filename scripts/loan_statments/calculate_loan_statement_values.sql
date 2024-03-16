


CREATE OR REPLACE FUNCTION calculate_loan_statement_values(v_loan_statement_id UUID)
RETURNS VOID AS $$
declare 
	v_expected_interest_amount float8;
	v_expected_principal_amount float8;
	v_expected_pay_date date;
	v_interest_amount_paid float8;
	v_principal_amount_paid float8;
	v_remaining_amount_to_be_paid float8;
	v_payment_status text;
	v_delete_date date;
	v_remaining_interest_amount_to_be_paid float8;
	v_remaining_principal_amount_to_be_paid float8;
begin
	perform create_debug_log_entry('calculate_loan_statement_values', 'start');
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_loan_statement_id: ' || v_loan_statement_id);

	perform check_loan_statement_exists(v_loan_statement_id);

	-- Is deleted
	select payment_status, delete_date from loan_statements ls 
	into v_payment_status, v_delete_date
	where id = v_loan_statement_id;

	-- Interest and principal amount paid
	select
		coalesce(sum(interest_amount_paid), 0),
		coalesce(sum(principal_amount_paid), 0)
	into v_interest_amount_paid, v_principal_amount_paid
	from payments
	where loan_statement_id = v_loan_statement_id
	and delete_date is null;

	-- Expected interest and principal amount paid as well as expected pay date
	select
		coalesce(expected_interest_amount, 0),
		coalesce(expected_principal_amount, 0),
		expected_pay_date
	into v_expected_interest_amount, v_expected_principal_amount, v_expected_pay_date
	from loan_statements ls 
	where id = v_loan_statement_id
	and payment_status not in ('deleted');

	-- Needed if there are no rows in "payments" as the into will be set to NULL (coalesce doesn't matter)
	if v_expected_interest_amount is null then v_expected_interest_amount := 0; end if;
	if v_expected_principal_amount is null then v_expected_principal_amount := 0; end if;

	-- Calculate remaining amount to be paid
	v_remaining_interest_amount_to_be_paid := v_expected_interest_amount - v_interest_amount_paid;
	if v_remaining_interest_amount_to_be_paid < 0 then v_remaining_interest_amount_to_be_paid = 0; end if;

	v_remaining_principal_amount_to_be_paid := v_expected_principal_amount - v_principal_amount_paid;
	if v_remaining_principal_amount_to_be_paid < 0 then v_remaining_principal_amount_to_be_paid = 0; end if;
	
	v_remaining_amount_to_be_paid := v_remaining_interest_amount_to_be_paid + v_remaining_principal_amount_to_be_paid;

	-- Calculate payment_status
	if v_payment_status = 'deleted' or v_delete_date is not null then -- Checks if current payment_status is deleted
		v_payment_status = 'deleted';
	elseif v_remaining_amount_to_be_paid <= 0 then
		v_payment_status = 'prompt';
	elseif v_expected_pay_date < CURRENT_DATE then
		v_payment_status = 'overdue';
	else
		v_payment_status = 'scheduled';
	end if;
	
	-- Update values
	update loan_statements 
	set
		interest_amount_paid = v_interest_amount_paid,
		principal_amount_paid = v_principal_amount_paid,
		payment_status = v_payment_status
	where id = v_loan_statement_id;

	perform create_debug_log_entry('calculate_loan_statement_values', 'v_payment_status: ' || v_payment_status);
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_interest_amount_paid: ' || coalesce(v_interest_amount_paid, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_principal_amount_paid: ' || coalesce(v_principal_amount_paid, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_expected_interest_amount: ' || coalesce(v_expected_interest_amount, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_expected_principal_amount: ' || coalesce(v_expected_principal_amount, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_expected_pay_date: ' || coalesce(v_expected_pay_date, '1990-01-01'));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_remaining_interest_amount_to_be_paid: ' || coalesce(v_remaining_interest_amount_to_be_paid, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_remaining_principal_amount_to_be_paid: ' || coalesce(v_remaining_principal_amount_to_be_paid, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'v_remaining_amount_to_be_paid: ' || coalesce(v_remaining_amount_to_be_paid, -1));
	perform create_debug_log_entry('calculate_loan_statement_values', 'end');
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('calculate_loan_statement_values', SQLERRM);
        RAISE EXCEPTION 'calculate_loan_statement_values - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
