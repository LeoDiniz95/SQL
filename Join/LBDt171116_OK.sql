/* ===========================================
LBDt - Aula de 09 de novembro de 2017
=========================
01. Descompacte o Banco de Dados, do arquivo ".zip" de 28/09, como LBDt171109_RA.fdb, registre-o e conecte-o (2 cliques sobre ele no FlameRobin)
02. Salve o ".sql" do item 12 de hoje, como LBDt171109_RA.sql, e abra-o no Editor (logo após conectar o LBDt171109_RA.fdb)
=============================================

/* ===========================================
STORED PROCEDURES:
=============================================
CREATE or ALTER PROCEDURE <NomedaProcedure>
	( <parâmetros de entrada> )
RETURNS 
	( <parâmetros de saída> )
AS
	<declaração de variáveis locais>
BEGIN
	<instruções SQL>
END
===========================================
-- Parâmetros de entrada:	Valores iniciais, que servem para estabelecer o comportamento do procedimento (todos os tipos, exceto BLOB ou ARRAY).
-- Parâmetros de saída:	Valores que retornam os resultados desejados, executados pelo procedimento (idem ao acima).
-- Instruções SQL:		Conjunto de instruções SQL/DML e DQL.
=========================================== */
/*======================
32.1.	Criar o Stored Procedure, SP_00, para executar as instruções acima, porém, para o autor, cujo código será informado via parâmetro.
====================== */
-- Antes, mostrar o nome, data de nascimento e país do autor, cujo código é 501:
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
EXECUTE PROCEDURE SP_00 (501);-- Experimente com outros códigos, válidos ou não...
SELECT  * from SP_00 (502);	-- Experimente com outros códigos, válidos ou não...
/*======================
32.2.	Criar o Stored Procedure, SP_01, para mostrar os nomes, datas de nascimento e países dos autores do país, cuja sigla será informada.
======================*/
select  nome, nascim, pais
from    Autor
where   UPPER (pais) = UPPER ('br')
--------------------------------------------
set term^;
Create or Alter Procedure SP_01
    (i_pais char (02))
RETURNS
    (o_nome    varchar (80),
     o_pais       char (02),
     o_nascim   date
    )
AS
BEGIN
        select  nome, nascim, pais
        from    Autor
        where   UPPER (pais) = UPPER (:i_pais)
        INTO    :o_nome, :o_nascim, :o_pais;
        SUSPEND;
END^
set term;^
commit;
-------------------------------------------- Executando...
SELECT  * from SP_01 ('br'); 		-- ERRO! Como o select traz mais que 2 respostas, deve-se usar "FOR/DO"
--------------------------------------------
set term^;
Create or Alter Procedure SP_01
    (i_pais char (02))
RETURNS
    (o_nome    varchar (80),
     o_pais       char (02),
     o_nascim   date
    )
AS
BEGIN
    FOR
        select  nome, nascim, pais
        from    Autor
        where   UPPER (pais) = UPPER (:i_pais)
        INTO    :o_nome, :o_nascim, :o_pais     -- retirar o ponto e virgula
    DO
    SUSPEND;
END^
set term;^
commit;
-------------------------------------------- Executando...
SELECT  * from SP_01 ('br'); 		-- ERRO! Como o select traz mais que 2 respostas, deve-se usar "FOR/DO"
SELECT  * from SP_01 ('US'); 	-- Agora, sim! 
/*======================
32.3.	Mostre os códigos e nomes dos livros, e nomes das editoras que os publicaram, porém somente dos livros publicados a partir de uma data informada como argumento de entrada no Stored Procedure
====================== */
-- 1º) Mostrar todos os dados dos livros lançados após uma determinada data
Select	* 
from 	livro
where	lancamento > '2013/10/10'
--------------------------------------------
-- 2º) Idem, mas deve-se também mostrar o nome da editora correspondente
Select	*
From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
Where	lancamento > '2013/10/10'
--------------------------------------------
-- 3º) Destes, mostrar somente o código e nome do livro, e nome da Editora
Select	L.codlivro, L.titulo, E.nome
From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
Where	lancamento > '2013/10/10'
--------------------------------------------
-- 4º) Por fim, criar a SP_02, utilizando esta lógica...
set term^;
Create or Alter Procedure SP_02
    (i_data     date)
RETURNS
    (o_codlivro smallint,
     o_titulo     varchar (80),
     o_nome    varchar (80)
    )
AS
BEGIN
    FOR
        Select	L.codlivro, L.titulo, E.nome
        From	Livro L INNER JOIN Editora E ON L.codedit = E.codedit
        Where	lancamento > :i_data
        
        INTO    :o_codlivro, :o_titulo, :o_nome
    DO
    SUSPEND;
end^
set term;^
commit;
--------------------------------------------
-- Experimente, com "2013/10/10" e outras datas...
Select  * from SP_02 ('2013/10/10');
--------------------------------------------
32.4.	Crie o SP para mostrar os nomes, datas de nascimento dos autores de algum país
select  nome, nascim , pais
from    Autor
where   pais = 'BR'
--------------------------------------------

--------------------------------------------
select  *
from    SP_Dados_Autor2 ('BR'); 	-- Oops! Há mais que 1 Autor de 'BR'
--------------------------------------------
-- Corrigir, pois há mais que 1 autor de 'BR'.
-- Usar o conjunto "FOR...DO…"
--------------------------------------------
…
BEGIN
    FOR
    select  nome, nascim, pais
    from    Autor
    where   pais = :i_pais
    INTO    :o_nome , :o_nascim , :o_pais 	-- Retirar o ";"!
    DO
    SUSPEND;
…
        
select  *
from    SP_Dados_Autor2 ('BR'); 
--------------------------------------------
-- Experimente com 'us'
-- Faça funcionar com 'US', em qualquer caixa (maiúsculas ou minúsculas), sempre.
/* ============================    
32.5.	Crie o procedimento "SP_AVGLivro" para calcular o preço médio dos livros publicados pela editora, cujo nome será informado externamente
============================ */
-- 1º) Encontrar o preço médio dos livros publicados por determinada editora
select  avg(preco) from    Livro
where   codedit = 
    (select codedit from Editora
      where nome = 'Marketing Books')
-- 2º) Criar o SP correspondente...
--------------------------------------------
set term^;
Create or Alter Procedure SP_AVGLivro
    (i_nomeEdit varchar (80))
RETURNS
    (o_precomed     numeric (10,2))
AS
BEGIN
    select  avg(preco) from    Livro
    where   codedit = 
        (select codedit from Editora
         where UPPER (nome) = UPPER (:i_nomeEdit)
        )

    INTO    :o_precomed;
    SUSPEND;
END^
set term;^
commit;
-------------------------------------------- Executando...
SELECT  * from SP_AVGLivro ('Marketing Books');
SELECT  o_precomed from SP_AVGLivro ('pearson education');
/* ============================    
32.6.	Mostre os títulos, datas de lançamento e valores de todos os livros, cujos preços sejam superiores ao preço médio, encontrado no Procedimento "AVGLivro" 	
SP_BuscaAVGLivro
*/
============================ */
Select      titulo, lancamento, preco
from    Livro
where   preco >
    (SELECT  o_precomed 
     from SP_AVGLivro ('Marketing Books'))
--------------------------------------------
Set term^;
Create or Alter Procedure SP_BuscaAVGLivro
    (i_nomeEditora  varchar (80))
RETURNS
    (o_titulo   varchar (80),
     o_lancamento   date,
     o_preco    numeric (10,2)
    )
AS
BEGIN
    FOR
        Select      titulo, lancamento, preco
        from    Livro
        where   preco >
        (SELECT  o_precomed 
         from SP_AVGLivro (:i_nomeEditora))

        INTO    :o_titulo, :o_lancamento, :o_preco
    DO
    SUSPEND;
END^
set term;^
commit;
--------------------------------------------
SELECT  * from SP_BuscaAVGLivro ('Marketing Books');
SELECT  o_titulo "Título", o_lancamento "Lançamento", o_preco "Preço"
from SP_BuscaAVGLivro ('mirandela editora');


 /* ============================
32.7. Crie o Stored Procedure "SP_Busca_Livros" para mostrar o código, título, nome da respectiva editora (se este determinado livro não tiver editora ainda, então informe: "-- não editado"), data de lançamento (se vazia, mostrar "-- não lançado") e preço, por ordem de preço decrescente, de todos os livros (tendo ou não sido publicados), cujos títulos contenham uma determinada palavra informada, em qualquer caixa, em qualquer posição do título.
    -- Sugestão: Faça o SELECT primeiramente...
============================*/
-- 1º Montando o SELECT:
-- Primeira tentativa (sem o que está entre parêntesis)...
SELECT L.codlivro, L.titulo, E.nome, L.lancamento, L.preco
FROM Livro L LEFT OUTER JOIN Editora E ON L.codedit = E.codedit
WHERE UPPER (L.titulo) LIKE UPPER ('%a%')
ORDER BY L.preco DESC

-- Segunda tentativa (agora, com o que está entre parêntesis = COALESCE)...
SELECT L.codlivro, L.titulo,
		COALESCE(E.nome, '-- Não editado') "Nome da editora", 
		COALESCE(L.lancamento, '-- Não lançado') "Data de lançamento",
		L.preco
FROM Livro L LEFT OUTER JOIN Editora E ON L.codedit = E.codedit
WHERE UPPER (L.titulo) LIKE UPPER ('%a%')
ORDER BY L.preco DESC

-- Montando o Stored Procedure
set term^;
CREATE or ALTER PROCEDURE SP_Busca_Livros
	(i_trechonome VARCHAR(40))
RETURNS
	(o_codlivro 	SMALLINT,
	 o_titulo 		VARCHAR(80),
	 o_nomedit 		VARCHAR(80),
	 o_lancamento 	VARCHAR(20),
	 o_preco 		NUMERIC(10,2)
	)
AS
BEGIN
	FOR
	SELECT L.codlivro, L.titulo,
			COALESCE (E.nome,'-- nao editado'),
			COALESCE (L.lancamento, '-- nao lancado'),
			L.preco
	FROM Livro L LEFT OUTER JOIN Editora E ON L.codedit = E.codedit
	WHERE UPPER(L.titulo) LIKE UPPER ('%'|| :i_trechonome ||'%')
	ORDER BY L.preco DESC
	
	INTO  :o_codlivro, :o_titulo, :o_nomedit, :o_lancamento, :o_preco
	
	DO
	SUSPEND;
END^

set term;^
COMMIT;
-- Executando...
SELECT * FROM SP_Busca_Livros('a')