
CREATE OR REPLACE FUNCTION calculate_loan_values(v_loan_id UUID)
RETURNS VOID AS $$
declare 
	v_loan_type text;
	v_interest_amount_paid float8;
	v_principal_amount_paid float8;
begin
	perform create_debug_log_entry('calculate_loan_values', 'start');

	-- Get variables
	select type
	into v_loan_type
	from loans l 
	where id = v_loan_id;

	if v_loan_type = 'open_ended_loan' then
		perform create_debug_log_entry('calculate_loan_values', 'open_ended_loan');
	
		-- Update principal_amount_paid and interest_amount_paid
		select sum(interest_amount_paid), sum(principal_amount_paid)
		into v_interest_amount_paid, v_principal_amount_paid
		from loan_statements
		where loan_id = v_loan_id
		and payment_status not in ('deleted');
	
		if v_interest_amount_paid = null then v_interest_amount_paid = 0; end if;
		if v_principal_amount_paid = null then v_principal_amount_paid = 0; end if;
	
		update open_ended_loans
		set interest_amount_paid = v_interest_amount_paid, principal_amount_paid = v_principal_amount_paid
		where loan_id = v_loan_id;
	
		perform create_debug_log_entry('calculate_loan_values', 'v_interest_amount_paid:' || v_interest_amount_paid);
		perform create_debug_log_entry('calculate_loan_values', 'v_principal_amount_paid:' || v_principal_amount_paid);
	elseif v_loan_type = 'zero_interest_loan' then
		perform create_debug_log_entry('calculate_loan_values', 'zero_interest_loan');
	
		select sum(principal_amount_paid)
		into v_principal_amount_paid
		from payments
		where loan_id = v_loan_id
		and delete_date is null;
	
		if v_principal_amount_paid is null then v_principal_amount_paid = 0; end if;
	
		-- Update remaining_amount_paid 
		update zero_interest_loans 
		set principal_amount_paid = v_principal_amount_paid
		where loan_id = v_loan_id;
	
		perform create_debug_log_entry('calculate_loan_values', 'v_principal_amount_paid:' || v_principal_amount_paid);
	else 
		RAISE exception 'calculate_loan_values - Unknown v_loan_type: %', v_loan_type;
	end if;

	-- Update payment status
	perform update_loan_payment_status(v_loan_id);
 	
	perform create_debug_log_entry('calculate_loan_values', 'end');
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('calculate_loan_values', SQLERRM);
        RAISE exception 'calculate_loan_values - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;