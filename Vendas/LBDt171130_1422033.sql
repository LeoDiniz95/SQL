-- Q01
select codprod,SUBSTRING(descri FROM 1 FOR 20)"Descricao",moeda, preuni
from produto
where descri like upper('%projetor%');

--Q02
SELECT moeda,COUNT(*),MIN(preuni),MAX(preuni),AVG(preuni) FROM PRODUTO
GROUP BY (moeda);

--Q03.

Select V.nrovenda, V.datvenda,Vr.nomvendr,Cli.nomcli,Pro.codprod,LOWER(Pro.descri) "Descricao",
       Iv.quantid,Pro.moeda,Pro.preuni,
       CASE WHEN Pro.codprod = Iv.codprod THEN Pro.preuni*Iv.quantid END "Total na moeda original",
       CASE WHEN Pro.Moeda = 'US$' THEN Pro.preuni*2 ELSE Pro.preuni END "Valor no R$",
       CASE WHEN Pro.Moeda = 'US$' THEN Pro.preuni*Iv.quantid*2 ELSE Pro.preuni*Iv.quantid END "Total em Reais"
from Venda V    inner join Vendedor     Vr  on  V.codvendr  = Vr.codvendr
                inner join ItemVend     Iv  on  V.nrovenda  = Iv.nrovenda
                inner join Produto      Pro on  Pro.codprod  = Iv.codprod
                inner join cliente      Cli on  Cli.codcli  = V.codcli
                
ORDER BY V.datvenda, V.nrovenda;


SET TERM^;
CREATE OR ALTER PROCEDURE Q03(
    i_nrovenda SMALLINT, i_datvenda DATE,
    i_nomvendr CHAR(36),i_nomecli CHAR(36),
    i_codpro CHAR(17), i_descri CHAR(100),
    i_quantid SMALLINT, i_moeda CHAR(4),
    i_preuni NUMERIC(8,2), i_totalOriginal Numeric(8,2),
    i_ValorReais Numeric(8,2),i_totalReais Numeric(8,2))
RETURNS(
    o_nrovenda SMALLINT, o_datvenda DATE,
    o_nomvendr CHAR(36), o_nomecli CHAR(36),
    o_codpro CHAR(17), o_descri CHAR(100),
    o_quantid SMALLINT, o_moeda CHAR(4),
    o_preuni NUMERIC(8,2), o_totalOriginal Numeric(8,2),
    o_ValorReais Numeric(8,2),o_totalReais Numeric(8,2))
    
AS
BEGIN
    FOR
    
        Select V.nrovenda, V.datvenda,Vr.nomvendr,Cli.nomcli,Pro.codprod,LOWER(Pro.descri) "Descricao",
                Iv.quantid,Pro.moeda,Pro.preuni,
                CASE WHEN Pro.codprod = Iv.codprod THEN Pro.preuni*Iv.quantid END "Total na moeda original",
                CASE WHEN Pro.Moeda = 'US$' THEN Pro.preuni*2 ELSE Pro.preuni END "Valor no R$",
                CASE WHEN Pro.Moeda = 'US$' THEN Pro.preuni*Iv.quantid*2 ELSE Pro.preuni*Iv.quantid END "Total em Reais"
        from Venda V    inner join Vendedor     Vr  on  V.codvendr  = Vr.codvendr
                inner join ItemVend     Iv  on  V.nrovenda  = Iv.nrovenda
                inner join Produto      Pro on  Pro.codprod  = Iv.codprod
                inner join cliente      Cli on  Cli.codcli  = V.codcli
                
            ORDER BY V.datvenda, V.nrovenda
    INTO :o_nrovenda , :o_datvenda, :o_nomvendr, :o_nomecli,
    :o_codpro , :o_descri , :o_quantid , :o_moeda,
    :o_preuni, :o_totalOriginal,
    :o_ValorReais, :o_totalReais
    DO
    SUSPEND;
END^
SET TERM;^
commit;

--Q04

SET TERM^;
CREATE or ALTER TRIGGER Q04
FOR Cliente
ACTIVE
BEFORE INSERT OR UPDATE OR DELETE
AS
BEGIN
    INSERT INTO LOG_CLIENTE (codcli,nomcli,ender,cidade,estado,cnpj,transac,operacao,data,hora)
    VALUES (COALESCE( NEW.codcli, old.codcli),
            COALESCE(new.nomcli,old.nomcli),
            COALESCE(new.ender,old.ender),
            COALESCE(new.cidade,old.cidade),
            COALESCE(new.estado,old.estado),
            COALESCE(new.cnpj,old.cnpj),
            current_transaction, current_role,
          	current_date, current_time
            )
    
END^
SET TERM;^