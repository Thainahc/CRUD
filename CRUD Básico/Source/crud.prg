#INCLUDE "WINUSER.CH"

*-------------*
FUNCTION MAIN()

   LOCAL GetList:={}, cOpcao:=" "

   SET DATE BRITISH

   IF !ISDIRECTORY("DBF")
      RUN("MD DBF")
   ENDIF

   IF !ISDIRECTORY("NTX")
      RUN("MD NTX")
   ENDIF

   IF !File("DBF\PRODUTO.DBF")
      DBCreate("DBF\PRODUTO.DBF",{{"CODIGO"  ,"N",005,0},;
                                  {"NOME"    ,"C",100,0},;
                                  {"PRECO"   ,"N",010,2},;
                                  {"CADASTRO","D",008,0},;
                                  {"INATIVO" ,"L",001,0}})
   ENDIF

   SELECT 0

   USE DBF\PRODUTO
   //Indice da tabela que ordena por codigo, o nome do indice � informado na tag, o arquivo � informado no to
   INDEX ON PRODUTO->CODIGO TAG "CODIGO" TO NTX\IND_PRODUTO

   SET INDEX TO NTX\IND_PRODUTO

   @ 01,00 SAY "Cadastro de Produtos:"
   @ 02,00 SAY "Informe a opcao (I - Inserir / A - Alterar / E - Excluir)" GET cOpcao PICT "@!" VALID OPCAO(cOpcao)

   READ
   //LIMPANDO AS TELAS ANTES DE CHAMAR A FUN��O
   CLEAR

   IF cOpcao == 'I'
      INCLUSAO()
    ELSEIF cOpcao == 'A'
      ALTERACAO()
    ELSEIF cOpcao == 'E'
      EXCLUSAO()
   ENDIF

RETURN NIL

*--------------------*
FUNCTION OPCAO(cOpcao)

   LOCAL lRetorno

   IF cOpcao <> 'I' .AND. cOpcao <> 'A' .AND. cOpcao <> 'E'
      MessageBox(,"Op��o inv�lida. Informe (I - Inserir / A - Alterar / E - Excluir)","Aten��o",MB_ICONEXCLAMATION)
      lRetorno:=.F.
    ELSE
      lRetorno:=.T.
   ENDIF

RETURN lRetorno

*-----------------*
FUNCTION INCLUSAO()

   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}

   @ 00,00 SAY "Informe os dados para a inclusao do produto"
   @ 01,00 SAY "Codigo   : "  Get nCodigo  PICT "99999"
   @ 02,00 SAY "Nome     : "  Get cNome    PICT "@!S30"
   @ 03,00 SAY "Preco    : "  Get nPreco   PICT "@E 999,999.99"
   @ 04,00 SAY "Cadastro : "  Get dCadastro
   @ 05,00 SAY "Inativo  : "  Get cInativo PICT "@!" VALID(cInativo$'SN')

   READ

   SELECT PRODUTO

   DBAppend()

   REPLACE CODIGO   WITH nCodigo
   REPLACE NOME     WITH cNome
   REPLACE PRECO    WITH nPreco
   REPLACE CADASTRO WITH dCadastro
   //REPLACE INATIVO  WITH cInativo=='S'

   IF cInativo=='S'
      REPLACE Inativo  WITH .T.
    ELSE
      REPLACE Inativo  WITH .F.
   ENDIF

   DBCommit()

RETURN NIL

*------------------*
FUNCTION ALTERACAO()

   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}

   @ 00,00 SAY "Informe o codigo do produto a ser alterado: " GET nCodigo

   READ

   CLEAR

   SELECT PRODUTO

   OrdSetFocus("CODIGO")

   IF DBSeek(nCodigo)  //busca o c�digo que a pessoa digitou
      cNome     :=PRODUTO->NOME
      nPreco    :=PRODUTO->PRECO
      dCadastro :=PRODUTO->CADASTRO
      cInativo  :=IIF(PRODUTO->Inativo,'S','N') //altera o l�gico para caractere, assim � exibido na tela

      @ 00,01 SAY "Codigo  : " GET nCodigo   PICT "99999" WHEN .F. //Usu�rio n�o consegue alterar o campo. When faz o usu�rio passar ou n�o
      @ 01,01 SAY "Nome    : " Get cNome     PICT "@!S30"
      @ 02,01 SAY "Preco   : " Get nPreco    PICT "@E 999,999.99"
      @ 03,01 SAY "Cadastro: " Get dCadastro
      @ 04,01 SAY "Inativo : " Get cInativo  PICT "@!" VALID(cInativo$'SN')

      READ

      SELECT PRODUTO
      RLock() //trava o registro que ser� alterado
      REPLACE NOME     WITH cNome
      REPLACE PRECO    WITH nPreco
      REPLACE CADASTRO WITH dCadastro
      //REPLACE ITATIVO  WITH cInativo=='S'

      IF cInativo =='S'
         REPLACE Inativo WITH .T.
       ELSE
         REPLACE Inativo WITH .F.
      ENDIF

      DBCommit() //salva as altera��es
      DBUnlock() //destrava o registro
    ELSE
      MessageBox(,"C�digo n�o encontrado. Informe novamente","Aten��o", MB_ICONEXCLAMATION)
   ENDIF

RETURN NIL

*-----------------*
FUNCTION EXCLUSAO()

   LOCAL nCodigo:=0, GetList:={}

   @ 00,00 SAY "Informe o codigo a ser excluido: " GET nCodigo VALID PRODUTO_CADASTRADO(nCodigo)

   READ

   CLEAR

   SELECT PRODUTO

   RLock()
   DELETE
   DBUnlock()

   MessageBox(,"Produto de c�digo " + AllTrim(Str(nCodigo)) + " exclu�do.")

RETURN NIL

*-----------------------------*
FUNCTION Busca_Produto(nCodigo)

   LOCAL lBuscou

   SELECT PRODUTO
   OrdSetFocus("CODIGO")

   lBuscou:=DBSeek(nCodigo) //DBSeek busca o codigo informado

RETURN lBuscou

*----------------------------------*
FUNCTION Produto_Cadastrado(nCodigo)

   LOCAL lRetorno:=.T.

   SELECT PRODUTO

   IF !Busca_Produto(nCodigo)
      MessageBox(,"Esse produto n�o est� cadastrado.")
      lRetorno:=.F.
   ENDIF

RETURN lRetorno