.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib


include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data 
outputIn db "Insira o nome do arquivo para ser lido: ", 0ah, 0h
coordenadaX db "Insira a coordenada x: ", 0ah, 0h
coordenadaY db "Insira a coordenada y: ", 0ah, 0h
larguraOut db "Insira a largura da censura: ", 0ah, 0h
alturaOut db "Insira a altura da censura: ", 0ah, 0h
outputOut db "Insira o nome do arquivo para ser escrito: ", 0ah, 0h

;input
inputFileIn db 50 dup(0)
inputFileOut db 50 dup(0)
coordX dd 0
coordY dd 0
larguraIn dd 0
alturaIn dd 0
stringAux db 50 dup(0)

;handles
inputHandle dd 0
outputHandle dd 0
fileBuffer dd 6480 dup(0)
fileHandle dd 0
fileOutHandle dd 0
console_count dd 0

readCount dd 0
writeCount dd 0

;Variaveis auxiliares
larguraImg dd 0
tamanhoLin dd 0
contador dd 0

.code 
censura:
    push esi        ; Salva o registrador esi (contador para armazenar o endereço do Array)
    push edi        ; Salva o registrador edi (contador para armazenar a coordenada do X da imagem)
    push edx        ; Salva o registrador edx (largura da imagem)
    push ebp        ; Salva o registrador ebp (topo da pilha)
    mov ebp, esp    ; Configura o ponteiro de base da pilha

    mov esi, DWORD PTR [ebp + 12] ;Endereço do Array
    
    mov edi, DWORD PTR [ebp + 8]  ;Coordenada inicial do X
    imul edi, 3                   ;Calcula qual o byte inicial da Censura
    
    mov edx, DWORD PTR [ebp + 4]  ;Cordenada Final do X
    imul edx, 3                   ;Calcula qual o tamanho em bytes da censura
    add ecx, edi                  ;Calcula qual o Byte Final da Censura

    applyCensura:
        mov byte ptr [esi + edi + 0], 0 ;Censura pixel B
        mov byte ptr [esi + edi + 1], 0 ;Censura pixel B
        mov byte ptr [esi + edi + 2], 0 ;Censura pixel B

        invoke WriteFile, fileOutHandle, addr fileBuffer, tamanhoLin, addr writeCount, NULL ;
        
        add edi, 3                      ;calcula o pixel
        
        cmp edi, edx                    ;valida se já chegou no final da censura
        jl applyCensura

    pop ebp ; Restaura o registrador ebx 
    pop edx ; Restaura o registrador edx 
    pop edi ; Restaura o registrador edi 
    pop esi ; Restaura o registrador esi s
    ret     ; Retorna a funçao

start:
; entrada de dados para o arquivo original

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax

invoke WriteConsole, outputHandle, addr outputIn, sizeof outputIn, addr console_count, NULL
invoke ReadConsole, inputHandle, addr inputFileIn, sizeof inputFileIn, addr console_count, NULL
mov esi, offset inputFileIn ;armazena apontador da string em esi
call trataString ;call function para tratar a string
; entrada de dados para o arquivo de saida

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr coordenadaX, sizeof coordenadaX, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr stringAux, sizeof stringAux, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset stringAux ;armazena apontador da string em esi
call trataString
invoke atodw, addr stringAux
mov coordX, eax

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr coordenadaY, sizeof coordenadaY, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr stringAux, sizeof stringAux, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset stringAux;armazena apontador da string em esi
call trataString
invoke atodw, addr stringAux
mov coordY, eax


invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr larguraOut, sizeof larguraOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr stringAux, sizeof stringAux, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset stringAux;armazena apontador da string em esi
call trataString
invoke atodw, addr stringAux
mov larguraIn, eax


invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr alturaOut, sizeof alturaOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr stringAux, sizeof stringAux, addr console_count, NULL

; tratamento da string do arquivo de saida
mov esi, offset stringAux ;armazena apontador da string em esi
call trataString
invoke atodw, addr stringAux
mov alturaIn, eax

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr outputOut, sizeof outputOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr inputFileOut, sizeof inputFileOut, addr console_count, NULL

; tratamento da string do arquivo de saida
mov esi, offset inputFileOut ;armazena apontador da string em esi
call trataString

;abre arquivo
invoke CreateFile, addr inputFileIn, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ; abre o arquivo para leitura
mov fileHandle, eax

;cria arquivo
invoke CreateFile, addr inputFileOut, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ;cria o arquivo para escrita
mov fileOutHandle, eax

;Copia dos 18 primeiros bytes
invoke ReadFile, fileHandle, addr fileBuffer, 18, addr readCount, NULL ;  
invoke WriteFile, fileOutHandle, addr fileBuffer, 18, addr writeCount, NULL ;

; Leitura dos 4 bytes da largura
invoke ReadFile, fileHandle, addr fileBuffer, 4, addr readCount, NULL ;
mov ebx, fileBuffer
mov larguraImg, ebx

; Escreve os 4 bytes da largura no novo arquivo
invoke WriteFile, fileOutHandle, addr fileBuffer, 4, addr writeCount, NULL

;Copia os 32 bytes
invoke ReadFile, fileHandle, addr fileBuffer, 32, addr readCount, NULL ;  
invoke WriteFile, fileOutHandle, addr fileBuffer, 32, addr writeCount, NULL ;

;Multiplicando a largura da imagem por 3 pra pegar o tamanho da linha
mov ebx, larguraImg
mov ebx, 3
mul ebx
mov tamanhoLin, ebx 

copyLoop:
        invoke ReadFile, fileHandle, addr fileBuffer4k, tamLinha, addr readCount, NULL ; 
        cmp readCount, 0
        je closeArq
        invoke WriteFile, fileOutHandle, addr fileBuffer4k, tamLinha, addr writeCount, NULL ;
        jmp copyLoop

CensuraLoop:
    invoke ReadFile, fileHandle, addr fileBuffer, tamanhoLin, addr readCount, NULL
    mov esi, offset fileBuffer
    mov edi, coordX
    mov ebx, larguraIn
    call censura
    mov ecx, alturaIn
    cmp ecx, contador
    je fechaArq
    inc contador
    jmp CensuraLoop

fechaArq:
    invoke CloseHandle, fileHandle ;fechando arquivo de entrada
    invoke CloseHandle, fileOutHandle ;fechado arquivo de escrita
    invoke ExitProcess, 0
end start