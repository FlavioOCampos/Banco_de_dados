-- create schema
-- create table nome_

create schema engenharia;

CREATE TABLE engenharia.depto(
	cod_dep int PRIMARY KEY,
	nome varchar (35)
);

CREATE TABLE engenharia.engenheiro(
	cod_eng int PRIMARY KEY,
	nome varchar(65),
	dt date,
	cod_dep int REFERENCES	engenharia.depto(cod_dep)
);

insert into engenharia.engenheiro (cod_eng, nome,dt,cod_dep) values (2, 'Saulo ','2024-10-01',1)
insert into engenharia.depto(cod_dep, nome) values (1, 'arquitetura'), ( 2,'RH ')