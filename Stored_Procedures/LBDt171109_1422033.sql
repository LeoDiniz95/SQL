/* ===========================================
STORED PROCEDURES:
=============================================
CREATE or ALTER PROCEDURE <NomedaProcedure>
	( <par�metros de entrada> )
RETURNS 
	( <par�metros de sa�da> )
AS
	<declara��o de vari�veis locais>
BEGIN
	<instru��es SQL>
END
===========================================
-- Par�metros de entrada:	Valores iniciais, que servem para estabelecer o comportamento do procedimento (todos os tipos, exceto BLOB ou ARRAY).
-- Par�metros de sa�da:	Valores que retornam os resultados desejados, executados pelo procedimento (idem ao acima).
-- Instru��es SQL:		Conjunto de instru��es SQL/DML e DQL.
=========================================== */
/*======================
32.1.	Criar o Stored Procedure, SP_00, para executar as instru��es acima, por�m, para o autor, cujo c�digo ser� informado via par�metro.
====================== */
-- Antes, mostrar o nome, data de nascimento e pa�s do autor, cujo c�digo � 501:
select  nome, nascim, pais
from    Autor
where   matricula = 501
--------------------------------------------
set term^;
CREATE or ALTER PROCEDURE SP_00
    (i_matricula    smallint)
RETURNS
    (o_nome     varchar (80),
     o_nascim   date,
     o_pais     char (02)
     )
AS
BEGIN
    select  nome, nascim, pais
    from    Autor
    where   matricula = :i_matricula
    INTO    :o_nome, :o_nascim, :o_pais;
    SUSPEND;
END^     
commit;
-------------------------------------------- Executando...
EXECUTE PROCEDURE SP_00 (501);-- Experimente com outros c�digos, v�lidos ou n�o...
SELECT  * from SP_00 (502);	-- Experimente com outros c�digos, v�lidos ou n�o...
/*======================
32.2.	Criar o Stored Procedure, SP_01, para mostrar os nomes, datas de nascimento e pa�ses dos autores do pa�s, cuja sigla ser� informada.
======================*/
select  nome, nascim, pais
from    Autor
where   UPPER (pais) = UPPER ('br')
--------------------------------------------
set term^;
CREATE or ALTER PROCEDURE SP_01
	(i_pais CHAR(02))
RETURNS
	(o_nome		VARCHAR(80),
	o_pais		CHAR(02),
	o_nascim	DATE
	)
AS
BEGIN
	select  nome, nascim, pais
	from    Autor
	where   UPPER (pais) = UPPER (:i_pais)
	INTO	:o_nome, :o_nascim, :o_pais;
	SUSPEND;
END^
set term;^
COMMIT;
-------------------------------------------- Executando...
SELECT  * from SP_01 ('br'); 		-- ERRO! Como o select traz mais que duas resposta, deve-se usar "FOR/DO"
--------------------------------------------
set term^;
CREATE or ALTER PROCEDURE SP_01
	(i_pais CHAR(02))
RETURNS
	(o_nome		VARCHAR(80),
	o_pais		CHAR(02),
	o_nascim	DATE
	)
AS
BEGIN
	FOR
		select  nome, nascim, pais
		from    Autor
		where   UPPER (pais) = UPPER (:i_pais)
		INTO	:o_nome, :o_nascim, :o_pais			--	retirar o ponto e virgula
	DO
	SUSPEND;
END^
set term;^
COMMIT;
-------------------------------------------- Executando...
SELECT  * from SP_01 ('br'); 		-- ERRO! Como o select traz mais que duas resposta, deve-se usar "FOR/DO"
SELECT  * from SP_01 ('US'); 	-- Agora, sim!
/*======================
32.3.	Mostre os c�digos e nomes dos livros, e nomes das editoras que os publicaram, por�m somente dos livros publicados a partir de uma data informada como argumento de entrada no Stored Procedure
====================== */
-- 1�) Mostrar todos os dados dos livros lan�ados ap�s uma determinada data
Select	* 
from 	livro
where	lancamento > '2013/10/10'
--------------------------------------------
-- 2�) Idem, mas deve-se tamb�m mostrar o nome da editora correspondente
Select	*
From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
Where	lancamento > '2013/10/10'
--------------------------------------------
-- 3�) Destes, mostrar somente o c�digo e nome do livro, e nome da Editora
Select	L.codlivro, L.titulo, E.nome
From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
Where	lancamento > '2013/10/10'
--------------------------------------------
-- 4�) Por fim, criar a SP_02, utilizando esta l�gica...
set term^;
CREATE or ALTER PROCEDURE SP_02
	(i_data date)
RETURNS
	(o_codlivro smallint,
	 o_titulo 	varchar(80),
	 o_nome 	varchar(80)
	)
AS
BEGIN
	FOR
		Select	L.codlivro, L.titulo, E.nome
		From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
		Where	lancamento > :i_data
		
		INTO :o_codlivro, :o_titulo, :o_nome
	DO
	SUSPEND;
END^
set term;^
commit;
--------------------------------------------
-- Experimente, com "2013/10/10" e outras datas...
Select  * from SP_02 ('2013/10/10');
--------------------------------------------
32.4.	Crie o SP para mostrar os nomes, datas de nascimento dos autores de algum pa�s
select  nome, nascim , pais
from    Autor
where   pais = 'BR'
--------------------------------------------

--------------------------------------------
select  *
from    SP_Dados_Autor2 ('BR'); 	-- Oops! H� mais que 1 Autor de 'BR'
--------------------------------------------
-- Corrigir, pois h� mais que 1 autor de 'BR'.
-- Usar o conjunto "FOR...DO�"
--------------------------------------------
�
BEGIN
    FOR
    select  nome, nascim, pais
    from    Autor
    where   pais = :i_pais
    INTO    :o_nome , :o_nascim , :o_pais 	-- Retirar o ";"!
    DO
    SUSPEND;
�
        
select  *
from    SP_Dados_Autor2 ('BR'); 
--------------------------------------------
-- Experimente com 'us'
-- Fa�a funcionar com 'US', em qualquer caixa (mai�sculas ou min�sculas), sempre.
/* ============================    
32.5.	Crie o procedimento "AVGLivro" para calcular o pre�o m�dio dos livros publicados pela editora, cujo nome ser� informado externamente
============================ */
-- 1�) Encontrar o pre�o m�dio dos livros publicados por determinada editora
select  avg(preco) from    Livro
where   codedit = 
    (select codedit from Editora
      where nome = 'Marketing Books')
-- 2�) Criar o SP correspondente...
--------------------------------------------
set term^;
CREATE or ALTER PROCEDURE SP_AVGLivro
	(i_nomeEdit VARCHAR(80))
RETURNS
	(o_precomed NUMERIC(10,2))
AS
BEGIN
	select  avg(preco) from    Livro
	where   codedit = 
    (select codedit from Editora
      where nome = :i_nomeEdit)
	  
	INTO :o_precomed;
	SUSPEND;
END^
set term;^
commit;
-------------------------------------------- Executando...
SELECT  * from SP_AVGLivro ('Marketing Books');
SELECT  o_precomed from SP_AVGLivro ('pearson education');
/* ============================    
32.6.	Mostre os t�tulos, datas de lan�amento e valores de todos os livros, cujos pre�os sejam superiores ao pre�o m�dio, encontrado no Procedimento "AVGLivro"
SP_BuscaAVGLivro
============================ */
Select      titulo, lancamento, preco
from    Livro
where   preco >
    (SELECT  o_precomed from SP_AVGLivro ('Marketing Books'))
--------------------------------------------
set term^;
CREATE or ALTER PROCEDURE SP_BuscaAVGLivro
	(i_nomeEditora VARCHAR(80))
RETURNS
	(o_titulo VARCHAR(80),
	o_lancamento date,
	o_preco NUMERIC(10,2)
	)
AS
BEGIN
	FOR
		SELECT 	titulo, lancamento, preco
		FROM 	Livro
        where   preco >
        (SELECT  o_precomed from SP_AVGLivro (:i_nomeEditora))
		
		INTO :o_titulo, :o_lancamento, :o_preco
	DO
	SUSPEND;
END^
set term;^
COMMIT;
--------------------------------------------
SELECT  * from SP_BuscaAVGLivro ('Marketing Books');
SELECT  o_titulo "Titulo", o_lancamento "Lan�amento", o_preco "Pre�o" from SP_BuscaAVGLivro ('mirandela editora');

 /* ============================
32.7.	10. Crie o Stored Procedure "SP_Busca_Livros" para mostrar os c�digos, t�tulos, datas de lan�amento (se vazia, mostrar "-- n�o lan�ado") e pre�o, por ordem de pre�o decrescente, de todos os livros, cujos t�tulos contenham uma determinada palavra informada, em qualquer caixa, em qualquer posi��o do t�tulo.
    -- Sugest�o: Fa�a o SELECT primeiramente...
============================*/
