create or replace function create_room(

	p_room_code varchar,
	p_room_name varchar,
	p_address varchar,
	p_capacity int4,
	p_section_code varchar,
	p_user_id int4,
	p_message out varchar,
	p_is_error out varchar

)as $$

declare

	v_room_pk int4;
	v_section_pk int4;
	v_values varchar;
	

begin
	p_is_error := false;
	select sec.id into v_section_pk from country_section sec
	where sec.section_code = p_section_code and sec.active = true;
	
	if not found then
		p_message := 'El codigo de la sección no existe en la base de datos';
		
	else
		
		insert into rooms_room(room_code, room_name, address, capacity, active, fk_section_id)
		values(p_room_code, p_room_name, p_address, p_capacity, true, v_section_pk);
		
		v_values := v_room_pk||','||p_room_code||','||p_room_name||','||p_address||','||p_capacity||','||'true'||','||v_section_pk;
		
		insert into rooms_auditorroom("action", "table", field, before_value, after_value, date, user_id)
		values('create', 'rooms_room', 'ALL', null, v_values, current_date,
		p_user_id);
		
		commit;
		
	end if;
	exception when others then
		p_message := 'Error en el sistema por favor comuniquese con el administrador. ' || SQLERRM;
		p_is_error := true;
		rollback;
end; $$

LANGUAGE plpgsql;

create or replace function edit_room(

	p_room_code varchar,
	p_room_name varchar,
	p_address varchar,
	p_capacity int4,
	p_section_code varchar,
	p_user_id int4,
	p_message out varchar,
	p_is_error out varchar

)as $$

declare 

	v_get_data varchar;
	v_room rooms_room%rowtype;
	v_section_pk int4;
	v_after_values varchar;
	v_before_values varchar;
	

begin
	
	p_is_error := false;
	
	select sec.id into v_section_pk from country_section sec
	where sec.section_code = p_section_code and sec.active = true;
	
	if not found then
		p_message := 'El codigo de la sección no existe en la base de datos';
		
	else
		
		select * into v_room from rooms_room ro
		where ro.room_code = p_room_code and ro.active = true;
		
		if not found then
			p_message = 'no existe el salon en la base de datos';
			
		else
			
			update rooms_room
			set room_name = p_room_name,
			address = p_address,
			capacity = p_capacity,
			fk_section_id = v_section_pk
			where room_code = p_room_code
			and active = true;
			
			v_before_values := v_room.id||','||v_room.room_code||','||v_room.room_name||','||v_room.address||','||v_room.capacity||','||'true'||','||v_room.fk_section_id;
			v_after_values := v_room_pk||','||p_room_code||','||p_room_name||','||p_address||','||p_capacity||','||'true'||','||v_section_pk;
			
			insert into rooms_auditorroom("action", "table", field, before_value, after_value, date, user_id)
			values('edit', 'rooms_room', 'ALL', v_before_values, v_after_values, current_date,
			p_user_id);
	
			commit;
			
		end if;
		
	end if;
	
	exception when others then
		p_message := 'Error en el sistema por favor comuniquese con el administrador. ' || SQLERRM;
		p_is_error := true;
		rollback;
	
	
end; $$
LANGUAGE plpgsql;

create or replace function delete_room(

	p_room_code varchar,
	p_user_id varchar,
	p_is_error out boolean,
	p_message out varchar

)as $$

declare
	v_room rooms_room%rowtype;
begin
	p_is_error := false;
	
	select * into v_room from rooms_room r
	where r.room_code = p_room_code and r.active = true;
	
	if not found then
	
		p_message := 'El salon no existe en la base de datos';
		
	else
		update rooms_room
		set active = false
		where id =  v_room.id;
		
		insert into rooms_auditorroom("action", "table", field, before_value, after_value, date, user_id)
		values('delete', 'rooms_room', 'active', p_room_code || ',true', p_room_code || 'false', current_date,
		p_user_id);
	
		p_message := 'El salon se ha eliminado de la base de datos';
		
		commit;
	end if;
	
	exception when others then
		p_message := 'Error en el sistema por favor comuniquese con el administrador, '|| SQLERRM;
		p_is_error := false;
		rollback;
end; $$
LANGUAGE plpgsql;



