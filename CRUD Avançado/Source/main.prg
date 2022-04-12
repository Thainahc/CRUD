#INCLUDE "INKEY.CH" //incluindo teclas de atalhos de teclada
#INCLUDE "WINUSER.CH"

FUNCTION MAIN()

   LOCAL nCodigo:=0, cNome:=Space(50), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}
   LOCAL aTitulos:={}, aCampos:={}

   SET EXACT OFF
   SET DATE BRITISH
   SET DELETE ON       //ON  - Reconhece o produto excluído e Atualiza a tela removendo o produto
                       //OFF - continua mantendo o registro na tela

   IF !ISDIRECTORY("DBF")
      RUN("MD DBF")
   ENDIF

   IF !ISDIRECTORY("NTX")
      RUN("MD NTX")
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

   INDEX ON PRODUTO->CODIGO TAG "CODIGO" TO NTX\IND_PRODUTO
   INDEX ON PRODUTO->NOME   TAG "NOME"   TO NTX\IND_PRODUTO

   SET INDEX TO NTX\IND_PRODUTO

   OrdSetFocus("NOME")
   DBGoTop()  //vai para o primeiro índice no banco de dados

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

*--------------------*
FUNCTION F_MAIN(nModo)

   IF nModo==4  //avalia se foi o usuário ou o programa que solicitou a telca. Enter e Esc são reconhecidos pelo programa
      //validando a tecla insert
      if LastKey()==K_INS
         INCLUIR()
       ELSEIF LastKey()==K_ENTER
         ALTERAR()
       ELSEIF LastKey()==K_DEL
         EXCLUIR()
       ELSEIF LastKey()>31 .AND. LastKey()<127
         BUSCAR()
      ENDIF
   ENDIF

RETURN 2  //retorna o DBedit para atualizar, retorna para o Cad. Produtos e redesenha o DBEdit

*----------------*
FUNCTION INCLUIR()

   LOCAL GetList:={}, nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N'

   SELECT PRODUTO

   @ 02,00 CLEAR TO 16,80

   @ 02,00 SAY PadC("Incluir",80)
   @ 03,00 SAY Replicate("-",80)

   @ 04,00 SAY "Codigo  :    " GET nCodigo   PICT "99999" VALID VERCODIGO(nCodigo)
   @ 05,00 SAY "Nome    :    " GET cNome     PICT "@!S30"
   @ 06,00 SAY "Preco   : R$ " GET nPreco    PICT "@E 999,999.99"
   @ 07,00 SAY "Cadastro:    " GET dCadastro
   @ 08,00 SAY "Inativo :    " GET cInativo  PICT "@!" VALID(cInativo$'SN')

   READ
   //se tecla diferente de ESC, irá fazer o cadastro.
   IF LastKey()<>K_ESC

      SELECT PRODUTO

      DBAppend() //abrindo campo em branco para ser preenchido

      REPLACE CODIGO   WITH nCodigo
      REPLACE NOME     WITH cNome
      REPLACE PRECO    WITH nPreco
      REPLACE CADASTRO WITH dCadastro
      //REPLACE INATIVO  WITH cInativo=='S'        outra forma de codificar o cInativo

      IF cInativo=='S'
         REPLACE INATIVO WITH .T.
       ELSE
         REPLACE INATIVO WITH .F.
      ENDIF

      DBCommit() //salvando o processo

      MessageBox(,"Produto cadastrado com sucesso.","Produto Incluído",MB_ICONINFORMATION)
   ENDIF

RETURN NIL

*------------------*
//verifica se o código informado já foi digitado
FUNCTION VERCODIGO(nCodigo)

   LOCAL lRetorno:=.T., cOrdem_Produto

   SELECT PRODUTO

   cOrdem_Produto:=OrdSetFocus("CODIGO") // Ordsetfocus() retorna a ordem atual (NOME).
                                         // Salvamos a ordem anterior em uma variável (NOME).
                                         // Mudamos a ordem atual para CODIGO.

   IF DBSeek(nCodigo)
      MessageBox(,"O código " + AllTrim(Str(nCodigo)) + "já está cadastrado","Atenção",MB_ICONEXCLAMATION)
      lRetorno:=.F.
   ENDIF

   OrdSetFocus(cOrdem_Produto) // Volta a ordem que estava antes (NOME)

RETURN lRetorno
*----------------*
FUNCTION ALTERAR()

   LOCAL nCodigo:=0, cNome:=Space(100), nPreco:=0, dCadastro:=Date(), cInativo:='N', GetList:={}

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

      REPLACE NOME     WITH cNome
      REPLACE PRECO    WITH nPreco
      REPLACE CADASTRO WITH dCadastro

      IF cInativo=='S'
         REPLACE INATIVO WITH .T.
       ELSEIF cInativo=='N'
         REPLACE INATIVO WITH .F.
      ENDIF

      DBCommit()

      DBUnlock()

      MessageBox(,"Produto alterado com sucesso.","Produto Alterado",MB_ICONINFORMATION)
   ENDIF

RETURN NIL

*----------------*
FUNCTION EXCLUIR()

   IF MessageBox(,"Deseja excluir o Produto?", "Atenção", MB_ICONWARNING+MB_YESNO)==IDYES
      SELECT PRODUTO

      RLock() //trava o registro que será excluido
      DELETE
      DBUnlock() //Destrava o Registro

      MessageBox(,"Produto excluído com sucesso","Produto Excluído", MB_ICONINFORMATION)
   ENDIF

RETURN NIL

*----------------*
FUNCTION BUSCAR()

   LOCAL cNome:=Space(100), GetList:={}
   LOCAL cOrdem_Produto, nRegistro_Produto
   LOCAL cPrimeira_Tecla

   cPrimeira_Tecla:=Chr(LastKey()) // No caso de o usuário apertar a letra "a": Lastkey() retorna 97 (tabela ASCII), Chr() converte 97 em "a"
   cNome:=PadR(cPrimeira_Tecla,100)
   //MessageBox(,"Primeira tecla: " + cPrimeira_Tecla)

   @ 11,14 CLEAR TO 14,70
   @ 11,14 TO 14,70
   @ 12,15 SAY "Digite o nome do produto:"
   @ 13,15 Get cNome PICTURE "@!S30"

   READ

   SELECT PRODUTO

   //salva a ordem antiga (codigo) e recebe uma nova (nome)
   cOrdem_Produto:=OrdSetFocus("NOME")
   nRegistro_Produto:=RecNo() //recNo retorna o número de registro que está na tabela Fox para controle do produto

   IF !DBSeek(AllTrim(cNome))
      MessageBox(,"O produto não foi encontrado.","Atenção",MB_ICONINFORMATION)
      DBGoTo(nRegistro_Produto)   //vai para a variável que estava posicionada a seleção antes de realizar o DBSeek
   ENDIF

   //depois de fazer a busca, retorna a ordem antiga que está na variável
   OrdSetFocus(cOrdem_Produto)

RETURN NIL

*-------------------*
FUNCTION RELATORIO()
   MessageBox(,"Entrou no Relatorio")
RETURN NIL