create table menu(
	
	id serial not null,
	menu_code varchar(64) not null,
	menu_label varchar not null,
	menu_url varchar not null,
	active boolean not null,
	version integer not null,
	fk_rol int4,
	constraint menu_key primary key(id),
	constraint fk_menu_rol foreign key(fk_rol) references roles_roles(id)

)

WITH (
	OIDS=FALSE
) ;

CREATE INDEX ix_menu ON public.menu (menu_code, active,fk_rol) ;


create table auditor_menu(

	id serial not null,
	"action" varchar not null,
	"table" varchar not null,
	field varchar not null,
	before_value varchar not null,
	after_value varchar not null,
	record_code varchar(64) not null,
	"date" date not null,
	user_id int4 not null,
	constraint pk_auditor_menu primary key(id),
	constraint fk_aud_men_user foreign key(user_id) references auth_user(id)

)

WITH (
	OIDS=FALSE
) ;

CREATE INDEX ix_auditor_menu ON public.auditor_menu ("action", "table",record_code ) ;