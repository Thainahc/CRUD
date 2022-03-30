FUNCTION MAIN()

   LOCAL nCodigo:=0, cNome:=Space(50), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}

   SET DATE BRITISH

   @ 00,00 SAY Date()
   @ 00,27 SAY "Cadastro de Produtos"
   @ 00,72 SAY Time()
   @ 01,00 SAY Replicate('-',80)

   RUN("MD DBF")

   DBCreate("DBF/PRODUTO.DBF", {{'CODIGO'  , 'N', 5,0},;
                                {'NOME'    , 'C', 100,0},;
                                {'PRECO'   , 'N', 10,2},;
                                {'CADASTRO', 'D', 8,0},;
                                {'INATIVO' , 'L', 1,0}})



   Inkey(0)

RETURN NIL