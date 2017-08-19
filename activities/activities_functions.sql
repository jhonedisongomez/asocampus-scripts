create or replace function validateSignInActivity(
	p_activity_code varchar(64),
	p_username varchar,
	out p_is_error boolean,
	out p_message varchar
	
)as $$

declare
	
	user_sign_up auth_user%rowtype;
	activity activities_activities%rowtype;
	sign_up_activities activities_signupactivities%rowtype;

begin
	p_is_error := false;
	
	
	select * into user_sign_up from auth_user us
	where us.username = p_username and us.is_active = true;
	
	if not found then
	
		p_message := 'el usuario no existe en la base de datos o no esta activo';
	
	else
		
		select * into activity from activities_activities act
		where act.activities_code = p_activity_code and act.active = true;
		
		if not found then
			p_message := 'la actividad no existe en la base de datos';
			
			else
			
				select into sign_up_activities from activities_signupactivities sact
				where sact.active = true and sact.fk_activities_id = activity.id
				and sact.fk_user_id = user_sign_up.id;
				
				if not found then
				
					p_message := 'El usuario no esta inscrito en la actividad';
				else
					p_message := 'El usuario esta inscrito en la base de datos';
				end if;
		end if;
	
	end if;
	
end; $$

LANGUAGE plpgsql;


