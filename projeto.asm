.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

.data 
outputIn db "Insira o nome do arquivo para ser lido", 0ah, 0h
outputOut db "Insira o nome do arquivo para ser escrito", 0ah, 0h
outputHandle dd 0

;input
inputFileIn db 50 dup(0)
inputFileOut db 50 dup(0)
inputHandle dd 0

fileBuffer db 14 dup(0)
bufferSize dd 0
readHandle dd 0
writeHandle dd 0
readCount dd 0
writeCount dd 0
console_count dd 0

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

invoke CreateFile, addr inputFileIn, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ; abre o arquivo para leitura
mov readHandle, eax
invoke ReadFile, readHandle, addr fileBuffer, 18, addr readCount, NULL ;Le 18 bytes do arquivo


invoke CreateFile, addr inputFileOut, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ;cria o arquivo para escrita
mov writeHandle, eax
invoke WriteFile, readHandle, addr fileBuffer, 18, addr writeCount, NULL ; Escreve 10 bytes do arquivo


invoke CloseHandle, writeHandle
invoke CloseHandle, readHandle

invoke ExitProcess, 0

end start