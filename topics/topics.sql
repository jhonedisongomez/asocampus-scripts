create or replace function create_topic(

	p_topic_code topics_topic.topic_code%type,
	p_topic_name topics_topic.topic_name%type,
	p_topic_desc topics_topic.description%type,
	p_user_pk auth_user.id%type,
	out p_is_error boolean,
	out p_message varchar

)as $$

declare
	v_values varchar;
begin
	
	p_is_error := false;
	insert into topics_topic(topic_code, topic_name, description, active)
	values(p_topic_code, p_topic_name, p_topic_desc, true);
	
	v_values := p_topic_code||','||p_topic_name||','||p_topic_desc||',true';
	
	insert into topics_auditortopic("action", "table", field, before_value, after_value, date, user_id)
	values('create', 'topics_topic', 'ALL', null, v_values, current_date,
	p_user_id);
	
	exception when others then
	
		p_is_error := true;
		p_message := 'Error en el sistema por favor comuniquese con el administrador. ' || SQLERRM;
		rollback;
	
end; $$

LANGUAGE plpgsql;



create or replace function edit_topic(

	p_topic_code topics_topic.topic_code%type,
	p_topic_name topics_topic.topic_name%type,
	p_topic_desc topics_topic.description%type,
	p_user_pk auth_user.id%type,
	out p_is_error boolean,
	out p_message varchar

)as $$

declare
	v_before_values topics_auditortopic.before_value%type;
	v_after_values topics_auditortopic.after_value%type;
	v_topic topics_topic%rowtype;
begin
	
	p_is_error := false;
	
	select * into v_topic from topics_topic top
	where top.topic_code = p_topic_code and top.active = true;
	
	if not found then
		p_message := 'No existe el tema en la base de datos';
		
	else
	
		update topics_topic
		set topic_name = p_topic_name,
		description = p_topic_desc
		where id = v_topic.id;
		
		v_before_values = v_topic.id ||','||v_topic.topic_code||','||v_topic.topic_name||','||v_topic.description||','||'true';
		v_after_values = v_topic.id ||','||p_topic_code||','||p_topic_name||','||p_topic_desc||','||'true';
		
		insert into rooms_auditorroom("action", "table", field, before_value, after_value, date, user_id)
		values('edit', 'topics_topic', 'ALL', v_before_values, v_after_values, current_date,
		p_user_id);
		
		commit;
		
		p_message := 'Se ha editado el tema';
	
	end if;
	
	exception when others then
		p_is_error := true;
		p_message := 'Error en el sistema por favor comuniquese con el administrador. ' || SQLERRM;
		rollback;
	
end; $$
LANGUAGE plpgsql;


create or replace function delete_topic(

	p_topic_code topics_topic.topic_code%type,
	p_user_pk auth_user.id%type,
	out p_is_error boolean,
	out p_message varchar
)as $$

declare

	v_before_values topics_auditortopic.before_value%type;
	v_after_values topics_auditortopic.after_value%type;
	v_topic topics_auditortopic%rowtype;
	
begin
	
	p_is_error := false;
	select * into v_topic from topics_topic top
	where top.topic_code = p_topic_code and top.active = true;
	
	if not found then
		p_message := 'El tema no existe en la base de datos';
		
	else
	
		update topics_topic
		set active = false
		where id = v_topic.id;
		
		insert into topics_topic("action", "table", field, before_value, after_value, date, user_id)
		values('delete', 'rooms_room', 'active', p_topic_code || ',true', p_topic_code || 'false', current_date,
		p_user_id);

		
		commit;
		
		p_message := 'El tema ha sido eliminado';
	
	end if;
	
	exception when others then
	
		p_is_error := true;
		p_message := 'Error en el sistema por favor comuniquese con el administrador. ' || SQLERRM;
		rollback;
	
end; $$
LANGUAGE plpgsql;

