create or replace function create_info_log_entry(v_method_name TEXT, v_description TEXT)
returns void as $$
declare 
	v_user_id UUID;
begin
    perform create_log_entry('info', v_method_name, v_description);
end;
$$ LANGUAGE plpgsql;
