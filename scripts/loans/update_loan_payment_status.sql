

------------- update_loan_payment_status ----------
CREATE OR REPLACE FUNCTION update_loan_payment_status(v_loan_id UUID)
RETURNS void AS $$
declare 
	v_loan_type text;
	v_delete_date date;
	v_payment_status text;
	v_has_overdue BOOLEAN;
	v_has_loans BOOLEAN;
	v_expected_pay_date date;
	v_initial_principal_amount float8;
	v_total_principal_amount_paid float8;
	v_remaining_principal_amount float8;
begin
	insert into log (origin, message) values ('update_loan_payment_status', 'start');

	select type, delete_date
	into v_loan_type, v_delete_date
	from loans
	where id = v_loan_id;

	if v_loan_type = 'zero_interest_loan' then
		insert into log (origin, message) values ('update_loan_payment_status', 'zero_interest_loan');
	
		select expected_pay_date, initial_principal_amount
		into v_expected_pay_date, v_initial_principal_amount
		from zero_interest_loans zil
		where loan_id = v_loan_id;
	
		-- Calculate paid principal amount
		select sum(principal_amount_paid)
		into v_total_principal_amount_paid
		from payments
		where loan_id = v_loan_id
		and delete_date is null;
	
		if v_total_principal_amount_paid is null then v_total_principal_amount_paid = 0; end if;
	
		-- Calculate remaining_principal_amount
		v_remaining_principal_amount = v_initial_principal_amount - v_total_principal_amount_paid;
	
		-- Calculate payment status
		if v_delete_date is not null then
			v_payment_status = 'deleted';
		elseif v_expected_pay_date is null then -- no expected date, indefinitely
			v_payment_status = 'prompt';
		elseif v_remaining_principal_amount <= 0 then
			v_payment_status = 'prompt';
		elseif v_expected_pay_date >= CURRENT_DATE then
			v_payment_status = 'prompt';
		else
			v_payment_status = 'overdue';
		end if;
	
		insert into log (origin, message) values ('update_loan_payment_status', 'v_payment_status:' || v_payment_status);
		insert into log (origin, message) values ('update_loan_payment_status', 'v_initial_principal_amount:' || v_initial_principal_amount);
		insert into log (origin, message) values ('update_loan_payment_status', 'v_total_principal_amount_paid:' || v_total_principal_amount_paid);
		insert into log (origin, message) values ('update_loan_payment_status', 'v_remaining_principal_amount:' || v_remaining_principal_amount);
	elseif v_loan_type in ('open_ended_loan') then
		-- Get payment status
		SELECT COUNT(*) > 0 INTO v_has_overdue
	    FROM loan_statements
	    where loan_id = v_loan_id
	    AND payment_status = 'overdue';
	    
	   	if v_delete_date is not null then
			v_payment_status = 'deleted';
	    elseIF v_has_overdue THEN
	        v_payment_status = 'overdue';
	    ELSE
	        v_payment_status = 'prompt';
	    END IF;	
	else
		RAISE EXCEPTION 'update_loan_payment_status - Unsupported v_loan_type: %', v_loan_type;
	end if;

	insert into log (origin, message) values ('update_loan_payment_status', 'v_payment_status:' || v_payment_status);

	update loans
	set payment_status = v_payment_status
	where id = v_loan_id;

	insert into log (origin, message) values ('update_loan_payment_status', 'end');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'update_loan_payment_status - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_loan_statement_exists(loan_statement_id UUID)
RETURNS void AS $$
DECLARE
    v_id UUID;
BEGIN
    -- Attempt to select the ID from loan_statements
    SELECT id INTO v_id FROM loan_statements WHERE id = loan_statement_id;
    
    -- Check if the SELECT statement found a row
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Loan statement with ID % not found.', loan_statement_id;
    END IF;
END;
$$ LANGUAGE plpgsql;
