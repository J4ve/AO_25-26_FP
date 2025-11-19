; =========================================================
; Employee Record Tracker - Phase 1: Add + Display
; =========================================================
section .data
    EOF equ -1
    MAX_EMPLOYEES equ 10
    EMPLOYEE_SIZE equ 64
    NAME_SIZE equ 32
    
    fmt_int db "%d", 0
    fmt_str db "%31s", 0
    fmt_display db "Name: %s - Position: %s", 10, 0
    
    menu_msg db 10, "## Employee Record Tracker ##", 10
             db "[1] Add Employee", 10
             db "[2] Delete Employee", 10
             db "[3] Search Employee", 10
             db "[4] Display Employees", 10
             db "[5] Exit", 10
             db "Enter your choice: ", 0
    
    display_menu db 10, "## Display Employees ##", 10
                 db "[1] Display all employees", 10
                 db "[2] Display employees by position", 10
                 db "Enter your choice: ", 0
    
    name_prompt db "Enter Name: ", 0
    pos_prompt db "Enter Position: ", 0
    db_full_msg db "Employee database is full.", 10, 0
    success_msg db "Employee added successfully!", 10, 0
    press_enter db 10, "Press Enter to continue...", 0
    exit_msg db "Exiting program.", 10, 0
    not_impl db "Feature not implemented yet.", 10, 0
    invalid_msg db "Invalid choice, please try again.", 10, 0
    
section .bss
    employees resb 640      ; 10 * 64 = 640 bytes
    count resd 1
    buffer resb 64
    choice resd 1
    
section .text
    global _main
    extern _printf, _scanf, _strcpy, _getchar
    
; ---------------------------------------------------------
; clear_stdin_buffer: flush remaining input until newline
; ---------------------------------------------------------
clear_stdin_buffer:
    push eax
.loop:
    call _getchar
    cmp eax, 10
    je .done
    cmp eax, EOF
    je .done
    jmp .loop
.done:
    pop eax
    ret
    
; ---------------------------------------------------------
; _main: program entry point
; ---------------------------------------------------------
_main:
    mov dword [count], 0
    
menu:
    push menu_msg
    call _printf
    add esp, 4
    
    push choice
    push fmt_int
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    mov eax, [choice]
    cmp eax, 1
    je add_emp
    cmp eax, 2
    je delete_emp
    cmp eax, 3
    je search_emp
    cmp eax, 4
    je display_menu_handler
    cmp eax, 5
    je exit
    
    push invalid_msg
    call _printf
    add esp, 4
    jmp menu
    
delete_emp:
    push not_impl
    call _printf
    add esp, 4
    jmp menu
    
search_emp:
    push not_impl
    call _printf
    add esp, 4
    jmp menu
    
; ---------------------------------------------------------
; add_emp: add a new employee
; ---------------------------------------------------------
add_emp:
    push ebp
    mov ebp, esp
    
    ; Check if database is full
    mov eax, [count]
    cmp eax, MAX_EMPLOYEES
    jge .full
    
    ; Get name
    push name_prompt
    call _printf
    add esp, 4
    
    push buffer
    push fmt_str
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    ; Copy to employee array
    mov eax, [count]
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    
    push buffer
    push edi
    call _strcpy
    add esp, 8
    
    ; Get position
    push pos_prompt
    call _printf
    add esp, 4
    
    push buffer
    push fmt_str
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    ; Copy position (offset +32)
    add edi, NAME_SIZE
    push buffer
    push edi
    call _strcpy
    add esp, 8
    
    inc dword [count]
    
    push success_msg
    call _printf
    add esp, 4
    
    mov esp, ebp
    pop ebp
    jmp menu
    
.full:
    push db_full_msg
    call _printf
    add esp, 4
    mov esp, ebp
    pop ebp
    jmp menu
    
; ---------------------------------------------------------
; display_menu_handler: handle display submenu
; ---------------------------------------------------------
display_menu_handler:
    push ebp
    mov ebp, esp
    
    push display_menu
    call _printf
    add esp, 4
    
    push choice
    push fmt_int
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    mov eax, [choice]
    cmp eax, 1
    je .display_all
    cmp eax, 2
    je .display_grouped
    
    push invalid_msg
    call _printf
    add esp, 4
    jmp .end
    
.display_grouped:
    push not_impl
    call _printf
    add esp, 4
    jmp .press_enter
    
.display_all:
    mov ecx, [count]
    cmp ecx, 0
    je .press_enter
    
    xor esi, esi
.loop:
    cmp esi, ecx
    jge .press_enter
    
    ; Save loop counter and limit
    push ecx
    push esi
    
    ; Calculate address
    mov eax, esi
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    
    ; Get position address
    mov ebx, edi
    add ebx, NAME_SIZE
    
    ; Print employee
    push ebx
    push edi
    push fmt_display
    call _printf
    add esp, 12
    
    ; Restore loop variables
    pop esi
    pop ecx
    
    inc esi
    jmp .loop
    
.press_enter:
    push press_enter
    call _printf
    add esp, 4
    call clear_stdin_buffer
    
.end:
    mov esp, ebp
    pop ebp
    jmp menu
    
; ---------------------------------------------------------
; exit: clean exit
; ---------------------------------------------------------
exit:
    push exit_msg
    call _printf
    add esp, 4
    ret
