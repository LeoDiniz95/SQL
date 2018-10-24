/* ---------------------------------------------------------------------
LBDt - Aula de 23 de novembro de 2017
==========================
01. Expanda o BD, do arquivo "Vendas171123.zip", no item 14, como "LBDt171123_RA.fdb".
02. Registre-o e conecte-o
==========================
03. Inicie o Editor SQL, salve o texto como "LBDt171123_RA.sql", e:
03.1. Explore o conte�do de cada tabela (observe se, na FK, h� NULL e quantos iguais h�)
03.2. Explore a estrutura de cada tabela e, baseado nelas, desenhe um DER b�sico (sem atributos), com os conjuntos de entidades, seus relacionamentos e cardinalidades. Enfim, descubra quem est� ligado a quem e com qual cardinalidade o faz...
==========================
03.3. Explore algumas fun��es (CAST, UPPER, LIKE, SUBSTRING, EXTRACT (DAY...), ...) inclusive as agrupadoras (COUNT, MAX, GROUP BY...)
==========================
03.4. Mostre dados espec�ficos, contidos em tabelas distintas (INNER e OUTER JOINs)
03.4.1. Entre apenas duas tabelas ligadas
03.4.2. Entre tr�s tabelas ligadas
03.4.3. Entre mais tabelas ligadas
03.4.4. Entre todas as tabelas
==========================
03.5. A partir de algumas das instru��es criadas, crie Stored Procedures, cujos par�metros sejam variados (como valores, datas, strings, parte de conte�dos, etc.).
==========================
03.6. Monte Triggers em fun��o de INSERT, UPDATE e DELETE em tabelas distintas, salvando valores e atributos fundamentais, tanto para o salvamento em si, quanto para trilha de auditoria (quem, quando, por onde se fez algo...).
==========================
Resolvendo...
03.1. Explore o conte�do de cada tabela (observe se, na FK, h� NULL e quantos iguais h�)
========================== */
select * from Cliente;
select * from Filial;
select * from ItemVend;
select * from Produto;
select * from Venda;
select * from Vendedor;
/* ==========================
03.3. Explore algumas fun��es (CAST, UPPER, LIKE, SUBSTRING, EXTRACT (DAY...), ...) inclusive as agrupadoras (COUNT, MAX, GROUP BY...)
========================== */
-- 1. Mostre os nomes dos clientes, definidos como CHAR, que tenham o �ltimo sobrenome "SILVA", em qualquer caixa
--------------------------------
select * from cliente;

select nomcli
from Cliente
where UPPER(nomcli) LIKE UPPER('%SILVA%');

--------------------------------
-- 1b. Mostre os nomes dos clientes, definidos como CHAR, que contenham "SILVA", em qualquer caixa
--------------------------------
select * from cliente;

select nomcli
from Cliente
where UPPER(TRIM(nomcli)) LIKE UPPER('%SILVA%');

--------------------------------
-- 2. Mostre os nomes dos clientes, que contenham "brazeel" em qualquer caixa
--------------------------------
select nomcli
from Cliente
where UPPER(TRIM(nomcli)) LIKE UPPER('%brazeel%');

--------------------------------
-- 3. Mostre do 10� ao 20� caractere dos nomes dos clientes
--------------------------------
select SUBSTRING(nomcli FROM 10 FOR 20)
from Cliente;

--------------------------------
-- 4. Mostre quantos caracteres h� no nome de cada cliente
--------------------------------
select CHAR_LENGTH(nomcli)
from Cliente;

select CHAR_LENGTH(TRIM(nomcli))
from Cliente;

--------------------------------
-- 5. Mostre o dia, m�s, ano, dia de semana e dia do ano (separados) de cada data de venda
--------------------------------
select  * from Venda;

select 	EXTRACT(DAY from datvenda) "Dia",
		EXTRACT(MONTH from datvenda) "M�s",
		EXTRACT(YEAR from datvenda) "Ano",
		EXTRACT(WEEKDAY from datvenda) "Dia da Semana",
		EXTRACT(YEARDAY from datvenda) "Dia do ano"
from Venda

-- 6. Mostre a data de cada venda e o dia de semana em que foram realizadas
--------------------------------
select 	EXTRACT(WEEKDAY from datvenda) "Dia da semana"
from Venda
-- Por extenso...
select datvenda,
		EXTRACT(WEEKDAY from datvenda) "Dia da Semana",
		CASE
			
			WHEN EXTRACT(WEEKDAY from datvenda) = 0 then 'Domingo'
			WHEN EXTRACT(WEEKDAY from datvenda) = 1 then 'Segunda'
			WHEN EXTRACT(WEEKDAY from datvenda) = 2 then 'Ter�a'
			WHEN EXTRACT(WEEKDAY from datvenda) = 3 then 'Quarta'
			WHEN EXTRACT(WEEKDAY from datvenda) = 4 then 'Quinta'
			WHEN EXTRACT(WEEKDAY from datvenda) = 5 then 'Sexta'
			ELSE 'S�bado'
			
		END
from Venda
            
-- 7. Mostre a descri��o, moeda e pre�o unit�rio de cada produto que contenha "mouse" ou "som" em qualquer posi��o e qualquer caixa
--------------------------------
select descri, moeda, preuni
from Produto
where UPPER(descri) LIKE UPPER('%mouse%')
OR UPPER(descri) LIKE UPPER ('%som%')

-- 8. Mostre a descri��o, moeda e pre�o unit�rio de cada produto em "R$"
--------------------------------
select  * from Produto;

select descri, moeda, preuni
from Produto
where moeda = 'R$'
--------------------------------
-- Fun��o de agrupamento(SUM, COUNT, AVG...)
--------------------------------
-- 9. Mostre o menor, maior e o pre�o m�dio dos produtos em cada moeda
--------------------------------
select moeda,MIN(preuni), MAX(preuni), COUNT(*), SUM(preuni), AVG(preuni)
from Produto
GROUP BY (moeda)

--------------------------------
-- 9b. Mostre o pre�o m�dio dos produtos em cada moeda
--------------------------------
select moeda, AVG(preuni)
from Produto
GROUP BY moeda

-- 10. Repita, por�m, ambas as m�dias devem ser expressas, tanto em R$, quanto em US$
--------------------------------

/* ==========================
03.4. Mostre dados espec�ficos, contidos em tabelas distintas (INNER e OUTER JOINs)
03.4.1. Entre apenas duas tabelas ligadas
03.4.2. Entre tr�s tabelas ligadas
03.4.3. Entre mais tabelas ligadas
03.4.4. Entre todas as tabelas
========================== */
-- 03.4.1. Entre apenas duas tabelas ligadas
--------------------------------
select * from ItemVend;
select * from Produto;
--------------------------------
-- 11. Mostre todos os dados dos itens de venda e dos produtos correspondentes
--------------------------------
select *
from ItemVend I INNER JOIN Produto P ON I.codprod = P.codprod

--------------------------------
-- 11b. Mostre o n�mero da venda, a descri��o, a quantidade, a moeda, o pre�o unit�rio e o pre�o total de cada item de venda
--------------------------------
select nrovenda, descri, quantid, moeda, preuni, quantid * preuni
from ItemVend I INNER JOIN Produto P ON I.codprod = P.codprod

--------------------------------
/* 12. Mostre o n�mero de venda, c�digo do produto, os 20 primeiros caracteres da descri��o, a quantidade, a moeda, o pre�o unit�rio e o pre�o total de cada produto vendido
--------------------------------*/
select 	nrovenda,
		SUBSTRING(descri FROM 1 FOR 20),
		quantid, moeda, preuni, quantid * preuni
from ItemVend I INNER JOIN Produto P ON I.codprod = P.codprod

--------------------------------
-- 03.4.4. Entre todas as tabelas
--------------------------------
select  * from Venda; 
select  * from Filial;
--------------------------------
/* 13. Mostre o n�mero e data da venda, a filial em que ocorreu, o nome do vendedor e o do cliente, o c�digo do produto, os 20 primeiros caracteres da descri��o, a quantidade, moeda, pre�o unit�rio e total de cada produto vendido.
--------------------------------*/
select 	V.nrovenda, datvenda,
		F.Cidade,
		nomvendr,
		nomcli,
		P.codprod,
		SUBSTRING(descri FROM 1 FOR 20),
		quantid, moeda, preuni, quantid * preuni
from	Venda V INNER JOIN Filial F 	ON V.nrFilial 	= F.nrFilial
				INNER JOIN Vendedor Vr 	ON V.codvendr 	= Vrcodvendr
				INNER JOIN Cliente C 	ON V.codcli 	= C.codcli
				INNER JOIN ItemVend I 	ON V.nrovenda 	= I.nrovenda
				INNER JOIN Produto P 	ON I.codprod 	= P.codprod

/* ==========================
03.5. A partir de algumas das instru��es criadas, crie Stored Procedures, cujos par�metros sejam variados (como valores, datas, strings, parte de conte�dos, etc.).
========================== */
-- 7. Mostre a descri��o, moeda e pre�o unit�rio de cada produto que contenha "mouse" ou "som" em qualquer posi��o e qualquer caixa
--------------------------------
set term ^;
Create or Alter Procedure SP_03_5_7
		(i_trecho1 varchar(36),
		 i_trecho2 varchar(36))
RETURNS
		(o_descri 	varchar(100),
		 o_moeda 	char(04),
		 o_preuni 	numeric(8,2))
AS
	BEGIN
		FOR
			select descri, moeda, preuni
			from Produto
			where UPPER(descri) LIKE UPPER ('%'||:i_trecho1||'%')
			OR 	  UPPER(descri) LIKE UPPER ('%'||:i_trecho2||'%')
			
			INTO :o_descri,:o_moeda,:o_preuni
		DO
		SUSPEND;
	END^
set term;^
commit;
--
select * from SP_03_5_7('som','mouse');
select * from SP_03_5_7('hdmi','led');

/* 14. Mostre o n�mero e data da venda, a filial em que ocorreu, o nome do vendedor e o do cliente, o c�digo do produto, os 20 primeiros caracteres da descri��o, a quantidade, moeda, pre�o unit�rio e total de cada produto vendido, por�m somente das filiais, cujos nomes contenham a palavra "centro" em qualquer caixa.
--------------------------------

--------------------------------
/* 15. Crie o Stored, "SP_03_5", com as mesmas instru��es do exerc�cio 14, por�m, cujo trecho de nome de filial seja informado externamente.
--------------------------------
--

--
Select * from SP_03_5 ('o');
==========================
03.6. Monte Triggers em fun��o de INSERT, UPDATE e DELETE em tabelas distintas, salvando valores e atributos fundamentais, tanto para o salvamento em si, quanto para trilha de auditoria (quem, quando, por onde se fez algo...).
==========================
