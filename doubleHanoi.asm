;nasm -f elf doubleHanoi.asm (cria arquivo fonte)

;ld -m elf_i386 -s -o doubleHanoi doubleHanoi.o (criar o executável do programa)

;./doubleHanoi(rodar no terminal do linux)

section .text
    global _start
    _start:
        
        
        ; pilha += endereço registrador
        push ebp  
        ; ebp = topo da pilha                      
        mov ebp, esp             

        ; torre hanoi 5 discos
        mov eax, 0x5   
        ; pilha += pino Via               
        push dword 0x3 
        ; pilha += pino B              
        push dword 0x2   
        ; pilha += pino A               
        push dword 0x1              
        ; pilha += eax (discos)    
        push eax 

        ; chamada funcao
        call mergeProblem               
        ; mesma coisa return
        mov eax, 1
        mov ebx, 0
        ; finaliza do main
        int 0x80                        

    mergeProblem:
        
        ;alocando a pilha 
        push ebp
        mov ebp,esp

        ;comparação para sair da recurssão 
        ; eax = topo da pilha
        mov eax,[ebp+8]  
        ; comparacao pra verificar parada                
        cmp eax,0x0 
        ; se true finaliza pilha                    
        jle finaliza                    

        ;step 1: mergeProblem
        
        ;parte recursiva, passa o mesmo parametro so diminui a quantidade de discos (-1)
        
        ; discos = discos - 1
        dec eax    
        ; pilha += pino A (parametro 1)                     
        push dword [ebp+12]   
        ; pilha += pino B (parametro 2)          
        push dword [ebp+16]  
        ; pilha += pino Via (parametro 3)           
        push dword [ebp+20] 
        ; quantidade de discos decrementada (parametro 4)            
        push dword eax                  
        call mergeProblem

        ;step 2: doubleTowers
        ;parte que vai passar pra outra função (parte de merge)

        ; pilha += pino A (parametro 1)
        push dword [ebp+12]  
        ;
        ; pilha += pino Via (parametro 2)           
        push dword [ebp+20]    
        ; pilha += pino B (parametro 3)         
        push dword [ebp+16]    
        ; quantidade de discos decrementada (parametro 4)         
        push dword eax                  
        call doubleTowers

        ;step 3: mover e imprimir

        ; alocando 12 bits
        add esp,12        
        ; pilha += pino B              
        push dword [ebp+16]    
        ; pilha += pino A         
        push dword [ebp+12]      
        ; pilha += discos       
        push dword [ebp+8]   
        ; imprimir           
        call imprimir                   
        
        ;step 4: doubleTowers

        ; alocando 12 bits
        add esp,12

        ; pino Via (parametro 1)
        push dword [ebp+20] 
        ; pino A (parametro 2)            
        push dword [ebp+12]
        ; pino B (parametro 3)       
        push dword [ebp+16]
        ; buscar quantidade de discos             
        mov eax,[ebp+8]     
        ; discos = discos - 1            
        dec eax               
        ; quantidade de discos decrementada (parametro 4)      
        push dword eax                  
        call doubleTowers
        jmp finaliza
    

    
    doubleTowers:

        push ebp
        mov ebp,esp
        
        ; eax = topo da pilha
        mov eax,[ebp+8]    
        ; comparacao pra verificar parada              
        cmp eax,0x0       
        ; se true finaliza pilha              
        jle finaliza                    

        ;step 1: doubleTowers


        ; decrementa 1 de eax
        dec eax             
        ; pilha += pino A (parametro 1)            
        push dword [ebp+12]     
        ; pilha += pino Via (parametro 2)        
        push dword [ebp+20]      
        ; pilha += pino B (parametro 3)       
        push dword [ebp+16]  
        ; quantidade de discos decrementada (parametro 4)
        push dword eax                
        call doubleTowers

        ;step 2: mover e imprimir

        ; alocando 12 bits
        add esp,12 
        ; pilha += pino A                     
        push dword [ebp+12]       
        ; pilha += pino B      
        push dword [ebp+16]    
        ; pilha += discos         
        push dword [ebp+8]  
        ; imprimir            
        call imprimir                   

        ;step 3: mover e imprimir

        ; alocando 12 bits
        add esp,12             
        ; pilha += pino A         
        push dword [ebp+12]  
        ; pilha += pino B           
        push dword [ebp+16]  
        ; pilha += discos           
        push dword [ebp+8]    
        ; imprimir          
        call imprimir                   
        
        ;step 4: doubleTowers
        
        add esp,12
        ; pilha += pino Via (parametro 1)
        push dword [ebp+20]   
        ; pilha += pino B (parametro 2)          
        push dword [ebp+16]   
        ; pilha += pino A (parametro 3)          
        push dword [ebp+12]      
         ; buscar quantidade de discos       
        mov eax,[ebp+8] 
        ; discos = discos - 1                
        dec eax             
        ; quantidade de discos decrementada (parametro 4)                
        push dword eax   
        ; recursividade               
        call doubleTowers               

    finaliza: 
        ;finaliza a chamada recursiva 
        ; guardando endreço pilha
        mov esp,ebp        
        ; desempilhar             
        pop ebp    
        ; return                     
        ret                             

    imprimir:

        ;salvo alguns registradores na pilha
        
        push ebp
        mov ebp, esp
        
        ;pra imprimir tem que mover os dados pra certos registradores especificos, que seria o ecx
        mov eax, [ebp + 12]
        add al, '0'
        ;coloca o valor do pino A na variavel 
        mov [pino_A], al
        

        mov eax, [ebp + 16]
        add al, '0'
        ;coloca o valor do pino B na variavel
        mov [pino_B], al

        ; é a chamada do sistema pra imprimir 
        ; os registradores recebem parametros especificos para a chamada do sistema imprimir 
        mov edx, lenght
        mov ecx, msg
        mov ebx, 1
        mov eax, 4
        int 0x80
        ; recuperar os registradores que foram salvos na pilha 
        mov esp, ebp
        pop ebp
        ret

section .data
    msg:
        db "movendo: "
        pino_A: db " "
        db " -> "
        pino_B: db " ", 0xa
        ;ver o tamanho mensagem 
        lenght equ $-msg