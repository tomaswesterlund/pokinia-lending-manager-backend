------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_client_payment_status(v_client_id UUID)
RETURNS void AS $$
declare 
	v_payment_status text;
	v_has_overdue BOOLEAN;
	v_has_loans BOOLEAN;
begin
	insert into log (origin, message) values ('update_client_payment_status', 'start');

	-- Get payment status
	SELECT COUNT(*) > 0 INTO v_has_loans
    FROM loans
    where client_id = v_client_id;
    
    if v_has_loans then
    	SELECT COUNT(*) > 0 INTO v_has_overdue
	    FROM loans
	    where client_id = v_client_id
	    AND payment_status = 'overdue';
	    
	    IF v_has_overdue THEN
	        v_payment_status = 'overdue';
	    ELSE
	        v_payment_status = 'prompt';
	    END IF;
    else
    	v_payment_status = 'empty';
    end if;
	
	
	insert into log (origin, message) values ('update_client_payment_status', 'v_payment_status:' || v_payment_status);

	update clients 
	set payment_status = v_payment_status
	where id = v_client_id;

	insert into log (origin, message) values ('update_client_payment_status', 'end');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An unexpected error occurred: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

