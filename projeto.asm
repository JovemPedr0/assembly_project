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
inputHandle dd 0
coordX dd 0
coordY dd 0
larguraIn dd 0
alturaIn dd 0

;handles
outputHandle dd 0
fileBuffer dd 0 
fileBuffer4k dd 6480 dup(0)
bufferSize dd 0
fileHandle dd 0
fileOutHandle dd 0
readCount dd 0
writeCount dd 0
console_count dd 0

;Variaveis auxiliares
largImage dd 0
tamLinha dd 0

.code 
start:
; entrada de dados para o arquivo original

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr outputIn, sizeof outputIn, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr inputFileIn, sizeof inputFileIn, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset inputFileIn ;armazena apontador da string em esi
    prxCaractereArqEntrada:
        mov al, [esi] ;move o caractere atual para al
        inc esi ;aponta para o proximo caractere
        cmp al, 13 ;verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereArqEntrada
        dec esi ;aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ;ASCII 0, terminador de string
        mov [esi], al ;insere ASCII 0 no lugar do ASCII CR

; entrada de dados para o arquivo de saida

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr coordenadaX, sizeof coordenadaX, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr coordX, sizeof coordX, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset coordX ;armazena apontador da string em esi
    prxCaractereCoordX:
        mov al, [esi] ;move o caractere atual para al
        inc esi ;aponta para o proximo caractere
        cmp al, 13 ;verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereCoordX
        dec esi ;aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ;ASCII 0, terminador de string
        mov [esi], al ;insere ASCII 0 no lugar do ASCII CR

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr coordenadaY, sizeof coordenadaY, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr coordY, sizeof coordY, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset coordY;armazena apontador da string em esi
    prxCaractereCoordY:
        mov al, [esi] ;move o caractere atual para al
        inc esi ;aponta para o proximo caractere
        cmp al, 13 ;verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereCoordY
        dec esi ;aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ;ASCII 0, terminador de string
        mov [esi], al ;insere ASCII 0 no lugar do ASCII CR


invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr larguraOut, sizeof larguraOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr larguraIn, sizeof larguraIn, addr console_count, NULL

; tratamento da string do arquivo de entrada
mov esi, offset larguraIn;armazena apontador da string em esi
    prxCaractereLargura:
        mov al, [esi] ;move o caractere atual para al
        inc esi ;aponta para o proximo caractere
        cmp al, 13 ;verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereLargura
        dec esi ;aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ;ASCII 0, terminador de string
        mov [esi], al ;insere ASCII 0 no lugar do ASCII CR


invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr alturaOut, sizeof alturaOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr alturaIn, sizeof alturaIn, addr console_count, NULL

; tratamento da string do arquivo de saida
mov esi, offset alturaIn ;armazena apontador da string em esi
    prxCaractereAltura:
        mov al, [esi] ; move o caractere atual para al
        inc esi ; aponta para o proximo caractere
        cmp al, 13 ; verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereAltura
        dec esi ; aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminador de string
        mov [esi], al ; insere ASCII 0 no lugar do ASCII CR

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
invoke WriteConsole, outputHandle, addr outputOut, sizeof outputOut, addr console_count, NULL

invoke GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
invoke ReadConsole, inputHandle, addr inputFileOut, sizeof inputFileOut, addr console_count, NULL

; tratamento da string do arquivo de saida
mov esi, offset inputFileOut ;armazena apontador da string em esi
    prxCaractereArqSaida:
        mov al, [esi] ; move o caractere atual para al
        inc esi ; aponta para o proximo caractere
        cmp al, 13 ; verifica se o caractere eh o ASCII CR - FINALIZAR
        jne prxCaractereArqSaida
        dec esi ; aponta para o caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminador de string
        mov [esi], al ; insere ASCII 0 no lugar do ASCII CR

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
mov eax, fileBuffer
mov largImage, eax

; Escreve os 4 bytes da largura no novo arquivo
invoke WriteFile, fileOutHandle, addr fileBuffer, 4, addr writeCount, NULL

;Copia os 32 bytes
invoke ReadFile, fileHandle, addr fileBuffer, 32, addr readCount, NULL ;  
invoke WriteFile, fileOutHandle, addr fileBuffer, 32, addr writeCount, NULL ;

;Multiplicando a largura da imagem por 3 pra pegar o tamanho da linha
mov eax, largImage
mov ebx, 3
mul ebx
mov tamLinha, eax 

copyLoop:
        invoke ReadFile, fileHandle, addr fileBuffer4k, tamLinha, addr readCount, NULL ; 
        cmp readCount, 0
        je closeArq
        invoke WriteFile, fileOutHandle, addr fileBuffer4k, tamLinha, addr writeCount, NULL ;
        jmp copyLoop

    closeArq:
        invoke CloseHandle, fileHandle ;fechando arquivo de entrada
        invoke CloseHandle, fileOutHandle ;fechado arquivo de escrita
    invoke ExitProcess, 0
end start