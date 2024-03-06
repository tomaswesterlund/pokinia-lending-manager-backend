------------- create_open_ended_loan ----------
create or replace function create_open_ended_loan(v_client_id UUID, v_start_date date, v_payment_period text, v_initial_principal_amount float8, v_interest_rate float8)
returns void as $$
declare 
	v_loan_id uuid;
	v_loan_statement_id uuid;
	v_expected_pay_date date;
begin
	insert into log (origin, message) values ('create_open_ended_loan', 'start');

	-- Create loans
	insert into loans(client_id, payment_status, type) values (v_client_id, 'unknown', 'open_ended_loan')
	returning id into v_loan_id;

	insert into open_ended_loans (loan_id, start_date, payment_period, initial_principal_amount, principal_amount_paid, interest_rate, interest_amount_paid)
	values (v_loan_id, v_start_date, v_payment_period, v_initial_principal_amount, 0, v_interest_rate, 0);

	-- Create loan_statements
	v_expected_pay_date := v_start_date;

	if v_payment_period = 'monthly' then
		while v_expected_pay_date < CURRENT_DATE + INTERVAL '6 months' loop
			-- Insert loan statement
			insert into loan_statements (loan_id, client_id, expected_pay_date, expected_interest_amount, expected_principal_amount, interest_amount_paid, principal_amount_paid, interest_rate, payment_status)
			values (
				v_loan_id, 
				v_client_id, 
				v_expected_pay_date,
				(v_initial_principal_amount * (v_interest_rate / 100)),
				0,
				0,
				0,
				v_interest_rate,
				'unknown'
			)
			returning id into v_loan_statement_id;
		
			perform calculate_loan_statement_values(v_loan_statement_id);

			-- Increase date
			v_expected_pay_date := v_expected_pay_date + interval '1 month';
			
		end loop;
	end if;
	
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	
	insert into log (origin, message) values ('create_open_ended_loan', 'end');
	
EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'create_open_ended_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;