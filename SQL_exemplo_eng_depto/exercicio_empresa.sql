create schema empresa

create table empresa.departamento(
	codigo int primary key,
	descricao varchar (85)	
	);

create table empresa.funcionario(
	matricula int primary key,
	nome varchar (55),
	codigo int not null,
	foreign key (codigo) references empresa.departamento(codigo)
	);

insert into empresa.departamento(codigo, descricao)
values (1,'RH'), (2, 'deptoFinanc'), (3,' Compras');

select codigo, descricao from empresa.departamento
select matricula, nome, codigo from empresa.funcionario



insert into empresa.funcionario(matricula, nome, codigo)	
values (200,'João', 1), (250, 'Gustavo', 2);
insert into empresa.funcionario(matricula, nome, codigo)
values (280,'João', 3);

update empresa.funcionario
SET matricula=280
where nome='Joaoo'