create or replace function create_log_entry(v_severity TEXT, v_method_name TEXT, v_description TEXT)
returns void as $$
declare 
	v_user_id UUID;
begin
    -- Get username
    SELECT current_setting('request.jwt.claim.sub') INTO v_user_id;

    -- Insert into log
    insert into log (source, severity, method_name, description, user_id)
    values ('database', v_severity, v_method_name, v_description, v_user_id);
end;
$$ LANGUAGE plpgsql;
