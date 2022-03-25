#INCLUDE "WINUSER.CH"
 FUNCTION MAIN()

   LOCAL GetList:={}, cOpcao:=" "
   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), lInativo:=.F.

   SET DATE BRITISH

   IF !ISDIRECTORY("DBF")
      RUN("MD DBF")
   ENDIF

   IF !ISDIRECTORY("NTX")
      RUN("MD NTX")
   ENDIF

   IF !File("DBF\PRODUTO.DBF")
      DBCreate("DBF\PRODUTO.DBF",{{"CODIGO","N",005,0},;
                                  {"NOME","C",100,0},;
                                  {"PRECO","N",010,2},;
                                  {"CADASTRO","D",008,0},;
                                  {"INATIVO","L",001,0}})
   ENDIF

   SELECT 0

   USE DBF\PRODUTO

   INDEX ON PRODUTO->CODIGO TAG "CODIGO" TO NTX\IND_PRODUTO

   SET INDEX TO NTX\IND_PRODUTO

   @ 01,00 SAY "Cadastro de Produtos:"
   @ 02,00 SAY "Informe a opcao (I - Inserir / A - Alterar / E - Excluir)" GET cOpcao PICT "@!" VALID OPCAO(cOpcao)

   READ

   IF cOpcao == 'I'
      @ 03,00 SAY "Informe os dados para a inclusao do produto"
      @ 04,00 SAY "Codigo   : "  GET nCodigo
      @ 05,00 SAY "Nome     : "  GET cNome
      @ 06,00 SAY "Preco    : "  GET nPreco PICT "@E 999,999.99"
      @ 07,00 SAY "Cadastro : "  GET dCadastro
      @ 08,00 SAY "Inativo  : "  GET lInativo

      READ

      INCLUSAO(nCodigo, cNome, nPreco, dCadastro, lInativo)
   ELSEIF cOpcao == 'A'
      ALTERACAO()
   ELSEIF cOpcao == 'E'
      EXCLUSAO(nCodigo)
   ENDIF

 RETURN NIL

 *----------------------*

 FUNCTION OPCAO(cOpcao)
   LOCAL lRetorno
   IF cOpcao <> 'I' .AND. cOpcao <> 'A' .AND. cOpcao <> 'E'
      MessageBox(,"Op��o inv�lida. Informe (I - Inserir / A - Alterar / E - Excluir)","Aten��o",MB_ICONEXCLAMATION)
      lRetorno:=.F.
    ELSE
      lRetorno:=.T.
   ENDIF
RETURN lRetorno

*--------------------------------*

FUNCTION INCLUSAO(nCodigo, cNome, nPreco, dCadastro, lInativo)

   SELECT PRODUTO

   DBAppend()

   REPLACE CODIGO   WITH nCodigo
   REPLACE NOME     WITH cNome
   REPLACE PRECO    WITH nPreco
   REPLACE CADASTRO WITH dCadastro
   REPLACE INATIVO  WITH lInativo

   DBCommit()

RETURN NIL

*-------------------------------------*

FUNCTION ALTERACAO()

   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), lInativo:=.F., GetList:={}

   CLEAR

   OrdSetFocus("CODIGO")

   IF DBSeek(nCodigo)
      nCodigo:=PRODUTO->CODIGO
      cNome:=PRODUTO->NOME
      nPreco:=PRODUTO->PRECO
      dCadastro:=PRODUTO->CADASTRO
      lInativo:=PRODUTO->INATIVO

      @ 00,00 SAY "Informe os dados a serem alterados:"
      @ 01,01 SAY "Nome    : " Get cNome
      @ 02,01 SAY "Preco   : " Get nPreco
      @ 03,01 SAY "Cadastro: " Get dCadastro
      @ 04,01 SAY "Inativo : " Get lInativo

   READ
    ELSE
      MessageBox(,"C�digo n�o encontrado. Informe novamente")
   ENDIF

   SELECT PRODUTO
   RLock() //trava o registro que ser� alterado
   REPLACE NOME     WITH cNome
   REPLACE PRECO    WITH nPreco
   REPLACE CADASTRO WITH dCadastro
   REPLACE ITATIVO  WITH cInativo=='S'
   DBCommit() //salva as altera��es
   DBUnlock() //destrava o registro

RETURN NIL

*------------------------------------*
FUNCTION EXCLUSAO()

   LOCAL nCodigo:=0, GetList:={}

   CLEAR

   SELECT PRODUTO

   //OrderFocous("CODIGO")

   @ 00,00 SAY "Informe o c�digo a ser exclu�do: " GET nCodigo


RETURN NIL




