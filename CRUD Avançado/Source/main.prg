#INCLUDE "INKEY.CH" //incluindo teclas de atalhos de teclada
#INCLUDE "WINUSER.CH"

FUNCTION MAIN()

   LOCAL nCodigo:=0, cNome:=Space(50), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}
   LOCAL aTitulos:={}, aCampos:={}

   SET DATE BRITISH

    IF !ISDIRECTORY("DBF")
      RUN("MD DBF")
   ENDIF

   IF !File("DBF\PRODUTO.DBF")
      DBCreate("DBF\PRODUTO.DBF",  {{'CODIGO'  , 'N', 5,0},;
                                    {'NOME'    , 'C', 100,0},;
                                    {'PRECO'   , 'N', 10,2},;
                                    {'CADASTRO', 'D', 8,0},;
                                    {'INATIVO' , 'L', 1,0}})

   ENDIF

   SELECT 0
   USE DBF\PRODUTO

   @ 00,00 SAY Date()
   @ 00,27 SAY "Cadastro de Produtos"
   @ 00,72 SAY Time()
   @ 01,00 SAY Replicate('-',80)
   @ 17,00 SAY Replicate('-',80)
   @ 18,00 SAY "INS - INCLUIR / ENTER - ALTERAR / DEL - EXCLUIR / LETRA - BUSCAR / F2 - RELATORIO"

   aTitulos:={"Codigo", "Nome"              , "Preco"}
   aCampos :={"CODIGO", "SUBSTR(NOME, 1,40)", "PRECO"}
   DBEdit(02,00, 16,80, aCampos,"F_MAIN",, aTitulos)

RETURN NIL

*----------------*
FUNCTION F_MAIN()
   //validando a tecla insert
   if LastKey()==K_INS
      INCLUIR()
    ELSEIF LastKey()==K_ENTER
      ALTERAR()
    ELSEIF LastKey()==K_DEL
      EXCLUIR()
   ENDIF

RETURN NIL

*----------------*
FUNCTION INCLUIR()

   LOCAL GetList:={}, nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N'

   CLEAR

   @ 00,00 SAY Date()
   @ 00,27 SAY "Cadastro de Produtos"
   @ 00,72 SAY Time()
   @ 01,00 SAY Replicate('-',80)
   @ 02,00 SAY PadC("Incluir",80)
   @ 03,00 SAY Replicate('-',80)
   @ 17,00 SAY Replicate('-',80)
   @ 18,00 SAY "INS - INCLUIR / ENTER - ALTERAR / DEL - EXCLUIR / LETRA - BUSCAR / F2 - RELATORIO"

   @ 04,00 SAY "Codigo  :    " GET nCodigo   PICT "99999"
   @ 05,00 SAY "Nome    :    " GET cNome     PICT "@!S30"
   @ 06,00 SAY "Preco   : R$ " GET nPreco    PICT "@E 999,999.99"
   @ 07,00 SAY "Cadastro:    " GET dCadastro
   @ 08,00 SAY "Inativo :    " GET cInativo  PICT "@!" VALID(cInativo$'SN')

   READ
   //se tecla diferente de ESC, irá fazer o cadastro.
   IF LastKey()<>K_ESC

      SELECT PRODUTO

      DBAppend() //abrindo campo em branco para ser preenchido

      Replace CODIGO   WITH nCodigo
      Replace Nome     WITH cNome
      Replace PRECO    WITH nPreco
      Replace CADASTRO WITH dCadastro
      Replace INATIVO  WITH cInativo=='S'
      /*outra forma de codificar o cInativo
      IF cInativo=='S'
         Replace INATIVO WITH .T.
       ELSE
         Replace INATIVO WITH .F.
      ENDIF  */

      DBCommit() //salvando o processo

      MessageBox(,"Produto Cadastrado.","Cadastrado",MB_ICONINFORMATION)
   ENDIF

RETURN NIL

*----------------*
FUNCTION ALTERAR()

   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}

   MessageBox(,'Alterar')

   SELECT PRODUTO

   @ 02,00 CLEAR TO 16,80

   nCodigo  :=PRODUTO->CODIGO
   cNome    :=PRODUTO->NOME  //pegando o valor existente no BD e jogando na variável cNome
   nPreco   :=PRODUTO->PRECO
   dCadastro:=PRODUTO->CADASTRO
   cInativo :=IIF(PRODUTO->INATIVO,"S","N")

   @ 02,00 SAY PadC("Alterar",80)
   @ 03,00 SAY Replicate('-',80)

   @ 04,00 SAY "Codigo  :    " GET nCodigo   PICT "99999" WHEN .F. //bloqueia a edição dessa variável
   @ 05,00 SAY "Nome    :    " GET cNome     PICT "@!S30"
   @ 06,00 SAY "Preco   : R$ " GET nPreco    PICT "@E 999,999.99"
   @ 07,00 SAY "Cadastro:    " GET dCadastro
   @ 08,00 SAY "Inativo :    " GET cInativo  PICT "@!" VALID(cInativo$'SN')

   READ

   IF LastKey()<>K_ESC
      SELECT PRODUTO

      RLock()

      Replace NOME     WITH cNome
      Replace PRECO    WITH nPreco
      Replace CADASTRO WITH dCadastro

      IF cInativo=='S'
         Replace INATIVO WITH .T.
       ELSEIF cInativo=='N'
         Replace INATIVO WITH .F.
      ENDIF

      DBCommit()

      DBUnlock()

      MessageBox(,"Produto alterado com sucesso.","Concluído",MB_ICONINFORMATION)
   ENDIF

RETURN NIL

*----------------*
FUNCTION EXCLUIR()
   MessageBox(,"Entrou no Excluir")
RETURN NIL

*----------------*
FUNCTION BUSCAR()
   MessageBox(,"Entrou no Buscarr")
RETURN NIL

*-------------------*
FUNCTION RELATORIO()
   MessageBox(,"Entrou no Relatorio")
RETURN NIL