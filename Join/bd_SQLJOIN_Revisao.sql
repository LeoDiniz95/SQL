-- Reforçando sobre JOINS:
____________________________________________________________________________
. Basicamente, e de forma mais convencional, os relacionamentos ocorrem entre as tabelas adjuntas, ou seja, aquelas que têm FK (chave estrangeira) com aquelas que têm a PK (chave primária) com conteúdo igual a desta FK (não necessariamente o nome do atributo, mas, sim, seu conteúdo).
. Se a Tabela A se relaciona com a Tabela B (FK de A e/ou FK de C), e esta com a Tabela C (FK de B, se FK de C não estiver em B), o JOIN deve ocorrer entre A e B e, depois, entre B e C.
. Se alguma tabela contiver tuplas com FK que podem estar NULL (vazias), no INNER JOIN não aparecerão, mas em OUTER JOIN (LEFT/RIGHT/FULL), podem.
____________________________________________________________________________
01. Primeiramente, observe os conteúdos das tabelas Livro e da Editora:
---------------------------------
select * from livro		-- Há um livro sem editora. Observe os codedit...
select * from editora	-- Há várias editoras sem livros (codedit / 2, 3, 4...)
____________________________________________________________________________
02. Agora, mostre os dados da tabela Livro e os da editora correspondente.
---------------------------------
select  *
from    Livro INNER JOIN Editora
on       Livro.codedit = Editora.codedit	
---------------------------------
-- Como codedit está em ambas, deve-se dizer de onde cada um vem! Por isto, "Livro." e "Editora.".
-- Observe, também, que o livro sem editora (null), não aparece, pois não há editora correspondente!
____________________________________________________________________________
03. Mostre apenas o título do livro (que só há em Livro) e o nome da editora (que só há em Editora):
---------------------------------
select  titulo , nome
from    Livro INNER JOIN Editora
on       Livro.codedit = Editora.codedit
____________________________________________________________________________
04. Ao invés de indicar o nome completo da tabela (Livro.codedit), use variável tupla (L.codedit):
---------------------------------
select  L.titulo , E.nome
from    Livro L INNER JOIN Editora E
on       L.codedit = E.codedit
____________________________________________________________________________
05. Volte a observar os conteúdos das tabelas Livro e Editora, pois experimentaremos OUTER JOINs:
---------------------------------
select * from livro
select * from editora
____________________________________________________________________________
06. Lembra-se do livro que está com codedit = NULL? Pois é, agora vamos mostrar os títulos de TODOS os livros (eu disse TODOS) e, havendo Editora correspondente, seu nome: 
---------------------------------
select  L.titulo , E.nome
from    Livro L LEFT OUTER JOIN Editora E	-- LEFT priorizará a tabela à esquerda = Livro!
on       L.codedit = E.codedit
---------------------------------
-- Viu, que agora há livro com codedit = NULL? Com INNER JOIN não mostraria.
____________________________________________________________________________
06b. "NULL" é muito esquisito de se mostrar, então, ao invés, mostre "-- sem editora"
---------------------------------
select  L.titulo , COALESCE (E.nome , '-- sem editora')
from    Livro L LEFT OUTER JOIN Editora E
on       L.codedit = E.codedit
---------------------------------
-- "Da hora", né?
____________________________________________________________________________
07. Experimente trocar LEFT por RIGHT:
---------------------------------
select  L.titulo , E.nome
from    Livro L RIGHT OUTER JOIN Editora E
on       L.codedit = E.codedit
---------------------------------
Úia! "Despriorizou" o Livro e priorizou a Editora! Lógico, pois Editora está à direita no FROM...
____________________________________________________________________________
08. Agora, sendo necessário mostrar TODOS os títulos dos Livros e TODOS os nomes de Editoras e sua correspondência. Neste caso, se não houver correspondência, aparecerão como NULL em uma ou em outra (se um Livro não for de alguma Editora, ou se alguma Editora não editou livros).
---------------------------------
select  L.titulo , E.nome
from    Livro L FULL OUTER JOIN Editora E
on       L.codedit = E.codedit
---------------------------------
Viu só?
____________________________________________________________________________
09. Mostrar todos os dados dos Livros e de seus Autores. 
-- Neste caso, observe que nem Livro, nem Autor, possui FK da outra, as quais estão na tabela Escreve, pois o relacionamento entre Livro e Autor é M:N (muitos para muitos, o que obriga a existência da tabela intermediária de relacionamento, Escreve, com ambas as FKs, também fazendo parte da PK composta PK = {codlivro , matricula}). 
-- Portanto, o JOIN deverá ocorrer entre Livro e Escreve, e entre Escreve e Autor. Veja:
---------------------------------
select  *
from    Livro L INNER JOIN Escreve Es ON L.codlivro = Es.codlivro	-- Livro:Escreve
                     INNER JOIN Autor Au ON Au.matricula = Es.matricula	-- Escreve:Autor
____________________________________________________________________________
10. Ao invés de mostrar todos os dados, mostre apenas o título do Livro e o nome do Autor:
---------------------------------
select  L.titulo , Au.nome
from    Livro L INNER JOIN Escreve Es ON L.codlivro = Es.codlivro
                     INNER JOIN Autor Au ON Au.matricula = Es.matricula
---------------------------------
-- Está ficando cada vez melhor, né?
____________________________________________________________________________
11. Mostre todos os dados dos Livros, de seus Autores, dos Assuntos e das Editoras correspondentes.
---------------------------------
select  *
from    Livro L INNER JOIN Escreve Es ON L.codlivro / Es.codlivro
                     INNER JOIN Autor Au ON Au.matricula / Es.matricula
                     INNER JOIN Assunto A ON A.sigla / L.sigla
                     INNER JOIN Editora Ed ON Ed.codedit / L.codedit
____________________________________________________________________________
12. Agora, mostre apenas o título de cada Livro, o nome de sua Editora, o nome de cada um de seus Autores e a descrição do Assunto correspondente
---------------------------------
select  L.titulo, Ed.nome, Au.nome, A.descricao
from    Livro L INNER JOIN Escreve Es ON L.codlivro / Es.codlivro
                     INNER JOIN Autor Au ON Au.matricula / Es.matricula
                     INNER JOIN Assunto A ON A.sigla / L.sigla
                     INNER JOIN Editora Ed ON Ed.codedit / L.codedit
---------------------------------
