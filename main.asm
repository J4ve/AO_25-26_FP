; Employee Record Tracker - NASM Win32 - FIXED (STDIN version)
; Compile with: nasm -f win32 employee.asm -o employee.o
; Link with: gcc -m32 employee.o -o employee.exe

extern _printf
extern _scanf
extern _getchar
extern _strcmp
extern _strcpy
extern _strlen
extern _stricmp
extern _fgets
extern _fdopen      ; ADDED: To get stdin handle dynamically

global _main

section .data
    ; Menu strings
    menu_title db 10,"========================================",10
                 db "      EMPLOYEE RECORD TRACKER SYSTEM",10
                 db "========================================",10,0
    menu_opt1 db "1. Add Employee",10,0
    menu_opt2 db "2. Delete Employee by Name",10,0
    menu_opt3 db "3. Delete Employee by Position",10,0
    menu_opt4 db "4. Search Employee by Name",10,0
    menu_opt5 db "5. Search Employee by Position",10,0
    menu_opt6 db "6. Display All Employees",10,0
    menu_opt7 db "7. Display Employees by Position (Grouped)",10,0
    menu_opt8 db "8. Exit",10,0
    menu_prompt db 10,"Enter choice (1-8): ",0
    
    ; Input prompts
    prompt_name db 10,"Enter employee name (max 49 chars): ",0
    prompt_position db "Enter employee position (max 49 chars): ",0
    prompt_delete_name db 10,"Enter name to delete: ",0
    prompt_delete_pos db 10,"Enter position to delete all employees: ",0
    prompt_search_name db 10,"Enter name to search: ",0
    prompt_search_pos db 10,"Enter position to search: ",0
    
    ; Messages
    msg_added db 10,"Employee added successfully!",10,0
    msg_deleted db 10,"Employee(s) deleted successfully!",10,0
    msg_not_found db 10,"Employee not found!",10,0
    msg_full db 10,"Error: Employee list is full (max 10 employees)!",10,0
    msg_empty db 10,"Error: No employees in the system!",10,0
    msg_invalid db 10,"Invalid choice! Please enter 1-8.",10,0
    msg_no_match db 10,"No employees found with that position!",10,0
    msg_confirm db 10,"Delete %d employee(s) with position '%s'? (y/n): ",0
    msg_cancelled db "Operation cancelled.",10,0
    msg_input_error db 10,"Input error or empty name/position.",10,0
    
    ; Display headers
    header_all db 10,"========================================",10
                 db "  NO.   NAME                  POSITION",10
                 db "========================================",10,0
    header_search db 10,"========================================",10
                   db "  SEARCH RESULTS",10
                   db "========================================",10,0
    header_grouped db 10,"========================================",10
                      db "  EMPLOYEES GROUPED BY POSITION",10
                      db "========================================",10,0
    format_employee db "  %-3d %-20s %-20s",10,0
    format_position_header db 10,"Position: %s",10
                            db "----------------------------------------",10,0
    
    ; Scanf formats
    scan_int db "%d",0
    scan_char db " %c",0
    
    ; File mode for fdopen
    mode_read db "r", 0
    
    MAX_EMPLOYEES equ 10
    NAME_SIZE equ 50
    POSITION_SIZE equ 50
    EMPLOYEE_RECORD_SIZE equ 100

section .bss
    ; Employee structure
    employees resb MAX_EMPLOYEES * EMPLOYEE_RECORD_SIZE
    employee_count resd 1
    choice resd 1
    temp_name resb NAME_SIZE
    temp_position resb POSITION_SIZE
    temp_char resb 1
    search_buffer resb NAME_SIZE
    
    ; Storage for stdin handle
    stdin_handle resd 1

section .text

; Helper function to remove trailing newline
remove_newline:
    push ebp
    mov ebp, esp
    mov esi, [ebp+8]
    push esi
    call _strlen
    add esp, 4 
    cmp eax, 0
    jz .done
    dec eax 
    add esi, eax
    cmp byte [esi], 0Ah 
    jne .done
    mov byte [esi], 0 
.done:
    mov esp, ebp
    pop ebp
    ret

_main:
    push ebp
    mov ebp, esp
    
    ; === FIX: Initialize STDIN Handle dynamically ===
    push mode_read      ; "r"
    push 0              ; File Descriptor 0 (Standard Input)
    call _fdopen
    add esp, 8
    mov [stdin_handle], eax  ; Store the FILE* pointer
    ; ================================================
    
    mov dword [employee_count], 0
    
main_loop:
    call display_menu
    call get_choice
    
    mov eax, [choice]
    cmp eax, 1
    je add_employee_handler
    cmp eax, 2
    je delete_by_name_handler
    cmp eax, 3
    je delete_by_position_handler
    cmp eax, 4
    je search_by_name_handler
    cmp eax, 5
    je search_by_position_handler
    cmp eax, 6
    je display_all_handler
    cmp eax, 7
    je display_grouped_handler
    cmp eax, 8
    je exit_program
    
    push msg_invalid
    call _printf
    add esp, 4
    jmp main_loop

add_employee_handler:
    call add_employee
    jmp main_loop

delete_by_name_handler:
    call delete_by_name
    jmp main_loop

delete_by_position_handler:
    call delete_by_position
    jmp main_loop

search_by_name_handler:
    call search_by_name
    jmp main_loop

search_by_position_handler:
    call search_by_position
    jmp main_loop

display_all_handler:
    call display_all
    jmp main_loop

display_grouped_handler:
    call display_grouped
    jmp main_loop

exit_program:
    xor eax, eax
    mov esp, ebp
    pop ebp
    ret

; ========== DISPLAY MENU ==========
display_menu:
    push ebp
    mov ebp, esp
    push menu_title
    call _printf
    add esp, 4
    push menu_opt1
    call _printf
    add esp, 4
    push menu_opt2
    call _printf
    add esp, 4
    push menu_opt3
    call _printf
    add esp, 4
    push menu_opt4
    call _printf
    add esp, 4
    push menu_opt5
    call _printf
    add esp, 4
    push menu_opt6
    call _printf
    add esp, 4
    push menu_opt7
    call _printf
    add esp, 4
    push menu_opt8
    call _printf
    add esp, 4
    mov esp, ebp
    pop ebp
    ret

; ========== GET CHOICE ==========
get_choice:
    push ebp
    mov ebp, esp
    push menu_prompt
    call _printf
    add esp, 4
    push choice
    push scan_int
    call _scanf
    add esp, 8
    call _getchar   ; Clear newline
    mov esp, ebp
    pop ebp
    ret

; ========== ADD EMPLOYEE ==========
add_employee:
    push ebp
    mov ebp, esp
    
    mov eax, [employee_count]
    cmp eax, MAX_EMPLOYEES
    jge .full
    
    push prompt_name
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword NAME_SIZE
    push temp_name
    call _fgets
    add esp, 12
    
    push temp_name
    call remove_newline
    add esp, 4
    
    push temp_name
    call _strlen
    add esp, 4
    test eax, eax
    jz .invalid_input
    
    push prompt_position
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword POSITION_SIZE
    push temp_position
    call _fgets
    add esp, 12
    
    push temp_position
    call remove_newline
    add esp, 4
    
    push temp_position
    call _strlen
    add esp, 4
    test eax, eax
    jz .invalid_input
    
    mov eax, [employee_count]
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov edi, employees
    add edi, eax
    
    push temp_name
    push edi
    call _strcpy
    add esp, 8
    
    add edi, NAME_SIZE
    push temp_position
    push edi
    call _strcpy
    add esp, 8
    
    inc dword [employee_count]
    
    push msg_added
    call _printf
    add esp, 4
    jmp .done

.full:
    push msg_full
    call _printf
    add esp, 4
    jmp .done

.invalid_input:
    push msg_input_error
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== DELETE BY NAME ==========
delete_by_name:
    push ebp
    mov ebp, esp
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push prompt_delete_name
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword NAME_SIZE
    push search_buffer
    call _fgets
    add esp, 12
    
    push search_buffer
    call remove_newline
    add esp, 4
    
    xor ecx, ecx    
.search_loop:
    cmp ecx, [employee_count]
    jge .not_found
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    
    push ecx           
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop ecx            
    
    test eax, eax
    jz .found
    
    inc ecx
    jmp .search_loop

.found:
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov edi, employees
    add edi, eax
    
    mov esi, edi
    add esi, EMPLOYEE_RECORD_SIZE
    
    mov eax, [employee_count]
    dec eax                 
    sub eax, ecx            
    mov edx, 100            
    mul edx                 
    
    push ecx                
    push ebx                
    mov ecx, eax            
    shr ecx, 2              
    rep movsd               
    pop ebx                 
    pop ecx                 
    
    dec dword [employee_count]
    
    push msg_deleted
    call _printf
    add esp, 4
    jmp .done

.not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp .done

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== DELETE BY POSITION ==========
delete_by_position:
    push ebp
    mov ebp, esp
    sub esp, 4
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push prompt_delete_pos
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword NAME_SIZE
    push search_buffer
    call _fgets
    add esp, 12
    
    push search_buffer
    call remove_newline
    add esp, 4
    
    xor ecx, ecx    
    xor edx, edx    
    mov dword [ebp-4], 0 
    
.count_loop:
    cmp ecx, [employee_count]
    jge .count_done
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    add esi, NAME_SIZE
    
    push ecx
    push edx
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop edx
    pop ecx
    
    test eax, eax
    jnz .count_next
    inc edx
    
.count_next:
    inc ecx
    jmp .count_loop

.count_done:
    mov [ebp-4], edx
    test edx, edx
    jz .no_match
    
    push search_buffer
    push edx
    push msg_confirm
    call _printf
    add esp, 12
    
    push temp_char
    push scan_char
    call _scanf
    add esp, 8
    call _getchar
    
    mov al, [temp_char]
    cmp al, 'y'
    je .do_delete
    cmp al, 'Y'
    je .do_delete
    
    push msg_cancelled
    call _printf
    add esp, 4
    jmp .done

.do_delete:
    xor ecx, ecx
.delete_loop:
    cmp ecx, [employee_count]
    jge .delete_done
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    mov edi, esi
    add esi, NAME_SIZE 
    
    push ecx
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop ecx
    
    test eax, eax
    jnz .delete_next
    
    mov esi, edi
    add esi, EMPLOYEE_RECORD_SIZE
    
    mov eax, [employee_count]
    dec eax                 
    sub eax, ecx            
    mov edx, 100
    mul edx                 
    
    push ecx                
    push ebx                
    mov ecx, eax            
    shr ecx, 2              
    rep movsd               
    pop ebx                 
    pop ecx                 
    
    dec dword [employee_count]
    jmp .delete_loop

.delete_next:
    inc ecx                 
    jmp .delete_loop

.delete_done:
    push msg_deleted
    call _printf
    add esp, 4
    jmp .done

.no_match:
    push msg_no_match
    call _printf
    add esp, 4
    jmp .done

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== SEARCH BY NAME ==========
search_by_name:
    push ebp
    mov ebp, esp
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push prompt_search_name
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword NAME_SIZE
    push search_buffer
    call _fgets
    add esp, 12
    
    push search_buffer
    call remove_newline
    add esp, 4
    
    xor ecx, ecx
.search_loop:
    cmp ecx, [employee_count]
    jge .not_found
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    
    push ecx
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop ecx
    
    test eax, eax
    jz .found
    
    inc ecx
    jmp .search_loop

.found:
    push header_search
    call _printf
    add esp, 4
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    
    push esi            
    add esi, NAME_SIZE
    push esi
    sub esi, NAME_SIZE
    push esi            
    
    mov eax, ecx
    inc eax
    push eax            
    push format_employee
    call _printf
    add esp, 16
    
    jmp .done

.not_found:
    push msg_not_found
    call _printf
    add esp, 4
    jmp .done

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== SEARCH BY POSITION ==========
search_by_position:
    push ebp
    mov ebp, esp
    sub esp, 4
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push prompt_search_pos
    call _printf
    add esp, 4
    
    ; FIX: Use [stdin_handle]
    push dword [stdin_handle]
    push dword NAME_SIZE
    push search_buffer
    call _fgets
    add esp, 12
    
    push search_buffer
    call remove_newline
    add esp, 4
    
    push header_search
    call _printf
    add esp, 4
    
    xor ecx, ecx
    mov dword [ebp-4], 0
    
.search_loop:
    cmp ecx, [employee_count]
    jge .check_found
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    
    push esi 
    add esi, NAME_SIZE
    
    push ecx
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop ecx
    pop esi 
    
    test eax, eax
    jnz .next
    
    inc dword [ebp-4]
    
    push esi            
    add esi, NAME_SIZE
    push esi
    sub esi, NAME_SIZE
    push esi            
    
    mov eax, ecx
    inc eax
    push eax            
    push format_employee
    call _printf
    add esp, 16
    
    pop esi
    pop esi
    
.next:
    inc ecx
    jmp .search_loop

.check_found:
    mov eax, [ebp-4]
    test eax, eax
    jnz .done
    
    push msg_no_match
    call _printf
    add esp, 4
    jmp .done

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== DISPLAY ALL ==========
display_all:
    push ebp
    mov ebp, esp
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push header_all
    call _printf
    add esp, 4
    
    xor ecx, ecx    ; Loop counter
    
.display_loop:
    cmp ecx, [employee_count]
    jge .done
    
    ; Calculate address of current employee
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    
    ; === CRITICAL FIX STARTS HERE ===
    
    ; 1. Save the Loop Counter
    ; printf will overwrite ECX, so we must save it on the stack
    push ecx  
    
    ; 2. Prepare Arguments for printf (Right-to-Left)
    
    ; Arg 3: Position String (Address is ESI + 50)
    lea eax, [esi + NAME_SIZE] 
    push eax
    
    ; Arg 2: Name String (Address is ESI)
    push esi
    
    ; Arg 1: Index Number (ECX + 1)
    mov eax, ecx
    inc eax
    push eax
    
    ; Arg 0: Format String
    push format_employee
    
    ; 3. Call printf
    call _printf
    add esp, 16     ; Clean up arguments (4 args * 4 bytes)
    
    ; 4. Restore the Loop Counter
    pop ecx
    
    ; === CRITICAL FIX ENDS HERE ===
    
    inc ecx
    jmp .display_loop

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret

; ========== DISPLAY GROUPED ==========
display_grouped:
    push ebp
    mov ebp, esp
    sub esp, MAX_EMPLOYEES * NAME_SIZE
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push header_grouped
    call _printf
    add esp, 4
    
    xor ecx, ecx
.outer_loop:
    cmp ecx, [employee_count]
    jge .done
    
    mov eax, ecx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov esi, employees
    add esi, eax
    add esi, NAME_SIZE
    
    push ecx
    push esi
    lea edi, [ebp - MAX_EMPLOYEES * NAME_SIZE]
    xor edx, edx
    
.check_displayed:
    cmp edx, ecx
    jge .not_displayed
    
    push edx
    push edi
    push esi
    call _strcmp
    add esp, 8
    pop edi
    pop edx
    
    test eax, eax
    jz .already_displayed
    
    add edi, NAME_SIZE
    inc edx
    jmp .check_displayed

.not_displayed:
    pop esi
    pop ecx
    
    push ecx
    push esi
    mov eax, ecx
    mov ebx, NAME_SIZE
    mul ebx
    lea edi, [ebp - MAX_EMPLOYEES * NAME_SIZE]
    add edi, eax
    
    push esi
    push edi
    call _strcpy
    add esp, 8
    
    pop esi
    pop ecx
    
    push esi
    push format_position_header
    call _printf
    add esp, 8
    
    push ecx
    xor edx, edx
.inner_loop:
    cmp edx, [employee_count]
    jge .inner_done
    
    mov eax, edx
    mov ebx, EMPLOYEE_RECORD_SIZE
    mul ebx
    mov edi, employees
    add edi, eax
    
    push edx
    push edi
    add edi, NAME_SIZE
    push esi
    push edi
    call _strcmp
    add esp, 8
    pop edi
    pop edx
    
    test eax, eax
    jnz .inner_next
    
    push edi            
    add edi, NAME_SIZE
    push edi
    sub edi, NAME_SIZE
    push edi            
    
    mov eax, edx
    inc eax
    push eax            
    push format_employee
    call _printf
    add esp, 16
    
    pop edi
    pop edi

.inner_next:
    inc edx
    jmp .inner_loop

.inner_done:
    pop ecx
    inc ecx
    jmp .outer_loop

.already_displayed:
    pop esi
    pop ecx
    inc ecx
    jmp .outer_loop

.empty:
    push msg_empty
    call _printf
    add esp, 4

.done:
    mov esp, ebp
    pop ebp
    ret