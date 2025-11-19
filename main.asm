; =========================================================
; Employee Record Tracker - Phase 2: Add + Display + Search
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
    
    search_menu db 10, "## Search Employee ##", 10
                db "[1] Search by Name", 10
                db "[2] Search by Position", 10
                db "Enter your choice: ", 0
    
    search_name_prompt db "Enter name to search: ", 0
    search_pos_prompt db "Enter position to search: ", 0
    not_found_msg db "No employees found.", 10, 0
    found_msg db "Found employee(s):", 10, 0
    
section .bss
    employees resb 640      ; 10 * 64 = 640 bytes
    count resd 1
    buffer resb 64
    choice resd 1
    found_flag resd 1       ; flag to track if any match found
    
section .text
    global _main
    extern _printf, _scanf, _strcpy, _getchar, _strcmp
    
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
    push ebp
    mov ebp, esp
    
    push search_menu
    call _printf
    add esp, 4
    
    push choice
    push fmt_int
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    mov eax, [choice]
    cmp eax, 1
    je .search_by_name
    cmp eax, 2
    je .search_by_position
    
    push invalid_msg
    call _printf
    add esp, 4
    jmp .end
    
.search_by_name:
    push search_name_prompt
    call _printf
    add esp, 4
    
    push buffer
    push fmt_str
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    mov dword [found_flag], 0
    mov ecx, [count]
    xor esi, esi
    
.loop_name:
    cmp esi, ecx
    jge .check_found
    
    push ecx
    push esi
    
    ; Get employee name address
    mov eax, esi
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    
    ; Compare strings
    push buffer
    push edi
    call _strcmp
    add esp, 8
    
    pop esi
    pop ecx
    
    ; If strcmp returns 0, strings match
    cmp eax, 0
    jne .next_name
    
    ; Print this employee if first match
    cmp dword [found_flag], 0
    jne .skip_header1
    
    push ecx
    push esi
    push found_msg
    call _printf
    add esp, 4
    pop esi
    pop ecx
    mov dword [found_flag], 1
    
.skip_header1:
    push ecx
    push esi
    
    mov eax, esi
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    mov ebx, edi
    add ebx, NAME_SIZE
    
    push ebx
    push edi
    push fmt_display
    call _printf
    add esp, 12
    
    pop esi
    pop ecx
    
.next_name:
    inc esi
    jmp .loop_name
    
.search_by_position:
    push search_pos_prompt
    call _printf
    add esp, 4
    
    push buffer
    push fmt_str
    call _scanf
    add esp, 8
    call clear_stdin_buffer
    
    mov dword [found_flag], 0
    mov ecx, [count]
    xor esi, esi
    
.loop_position:
    cmp esi, ecx
    jge .check_found
    
    push ecx
    push esi
    
    ; Get employee position address
    mov eax, esi
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    add edi, NAME_SIZE
    
    ; Compare strings
    push buffer
    push edi
    call _strcmp
    add esp, 8
    
    pop esi
    pop ecx
    
    ; If strcmp returns 0, strings match
    cmp eax, 0
    jne .next_position
    
    ; Print this employee if first match
    cmp dword [found_flag], 0
    jne .skip_header2
    
    push ecx
    push esi
    push found_msg
    call _printf
    add esp, 4
    pop esi
    pop ecx
    mov dword [found_flag], 1
    
.skip_header2:
    push ecx
    push esi
    
    mov eax, esi
    imul eax, EMPLOYEE_SIZE
    lea edi, [employees]
    add edi, eax
    mov ebx, edi
    add ebx, NAME_SIZE
    
    push ebx
    push edi
    push fmt_display
    call _printf
    add esp, 12
    
    pop esi
    pop ecx
    
.next_position:
    inc esi
    jmp .loop_position
    
.check_found:
    cmp dword [found_flag], 0
    jne .press_enter
    push not_found_msg
    call _printf
    add esp, 4
    
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
