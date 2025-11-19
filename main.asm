; Employee Record Tracker - NASM Win32
; Compile with: nasm -f win32 employee.asm -o employee.o
; Link with: gcc -m32 employee.o -o employee.exe

extern _printf
extern _scanf
extern _getchar
extern _strcmp
extern _strcpy
extern _strlen
extern _stricmp

global _main

section .data
    ; Menu strings
    menu_title db 10,"========================================",10
               db "    EMPLOYEE RECORD TRACKER SYSTEM",10
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
    
    ; Display headers
    header_all db 10,"========================================",10
               db "  NO.  NAME                POSITION",10
               db "========================================",10,0
    header_search db 10,"========================================",10
                  db "  SEARCH RESULTS",10
                  db "========================================",10,0
    header_grouped db 10,"========================================",10
                   db "  EMPLOYEES GROUPED BY POSITION",10
                   db "========================================",10,0
    format_employee db "  %-3d  %-20s %-20s",10,0
    format_position_header db 10,"Position: %s",10
                           db "----------------------------------------",10,0
    
    ; Scanf formats
    scan_int db "%d",0
    scan_str db "%49s",0
    scan_char db " %c",0
    
    MAX_EMPLOYEES equ 10
    NAME_SIZE equ 50
    POSITION_SIZE equ 50

section .bss
    ; Employee structure: name (50 bytes) + position (50 bytes) = 100 bytes
    employees resb MAX_EMPLOYEES * 100
    employee_count resd 1
    choice resd 1
    temp_name resb NAME_SIZE
    temp_position resb POSITION_SIZE
    temp_char resb 1
    search_buffer resb NAME_SIZE

section .text
_main:
    push ebp
    mov ebp, esp
    
    ; Initialize employee count
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
    
    ; Invalid choice
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
    
    call _getchar  ; Clear newline
    
    mov esp, ebp
    pop ebp
    ret

; ========== ADD EMPLOYEE ==========
add_employee:
    push ebp
    mov ebp, esp
    
    ; Check if full
    mov eax, [employee_count]
    cmp eax, MAX_EMPLOYEES
    jge .full
    
    ; Get name
    push prompt_name
    call _printf
    add esp, 4
    
    push temp_name
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    ; Validate name (check if not empty)
    push temp_name
    call _strlen
    add esp, 4
    test eax, eax
    jz .invalid_input
    
    ; Get position
    push prompt_position
    call _printf
    add esp, 4
    
    push temp_position
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    ; Validate position
    push temp_position
    call _strlen
    add esp, 4
    test eax, eax
    jz .invalid_input
    
    ; Calculate offset for new employee
    mov eax, [employee_count]
    mov ebx, 100  ; Size of each employee record
    mul ebx
    mov edi, employees
    add edi, eax
    
    ; Copy name
    push temp_name
    push edi
    call _strcpy
    add esp, 8
    
    ; Copy position
    add edi, NAME_SIZE
    push temp_position
    push edi
    call _strcpy
    add esp, 8
    
    ; Increment count
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
    push msg_invalid
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
    
    ; Check if empty
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    ; Get name to delete
    push prompt_delete_name
    call _printf
    add esp, 4
    
    push search_buffer
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    ; Search and delete
    xor ecx, ecx  ; Index counter
    
.search_loop:
    cmp ecx, [employee_count]
    jge .not_found
    
    ; Calculate offset
    mov eax, ecx
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    
    ; Compare names (case-insensitive)
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    
    test eax, eax
    jz .found
    
    inc ecx
    jmp .search_loop

.found:
    ; Shift all employees after this one
    mov edi, ecx  ; Start index
    
.shift_loop:
    mov eax, edi
    inc eax
    cmp eax, [employee_count]
    jge .shift_done
    
    ; Calculate source (next employee)
    mov eax, edi
    inc eax
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    
    ; Calculate destination (current employee)
    mov eax, edi
    mov ebx, 100
    mul ebx
    mov edx, employees
    add edx, eax
    
    ; Copy 100 bytes
    push ecx
    mov ecx, 100
    rep movsb
    pop ecx
    
    inc edi
    jmp .shift_loop

.shift_done:
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
    sub esp, 8
    
    ; Check if empty
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    ; Get position to delete
    push prompt_delete_pos
    call _printf
    add esp, 4
    
    push search_buffer
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    ; Count matches first
    xor ecx, ecx  ; Index
    xor edx, edx  ; Match count
    mov dword [ebp-4], 0  ; Store match count
    
.count_loop:
    cmp ecx, [employee_count]
    jge .count_done
    
    mov eax, ecx
    mov ebx, 100
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
    
    ; Confirm deletion
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
    ; Delete all matching positions
    xor ecx, ecx
    
.delete_loop:
    cmp ecx, [employee_count]
    jge .delete_done
    
    mov eax, ecx
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    add esi, NAME_SIZE
    
    push ecx
    push search_buffer
    push esi
    call _stricmp
    add esp, 8
    pop ecx
    
    test eax, eax
    jnz .delete_next
    
    ; Found match, shift array
    mov edi, ecx
    
.shift_loop2:
    mov eax, edi
    inc eax
    cmp eax, [employee_count]
    jge .shift_done2
    
    mov eax, edi
    inc eax
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    
    mov eax, edi
    mov ebx, 100
    mul ebx
    push edi
    mov edi, employees
    add edi, eax
    
    push ecx
    mov ecx, 100
    rep movsb
    pop ecx
    pop edi
    
    inc edi
    jmp .shift_loop2

.shift_done2:
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
    
    push search_buffer
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    xor ecx, ecx
    
.search_loop:
    cmp ecx, [employee_count]
    jge .not_found
    
    mov eax, ecx
    mov ebx, 100
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
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    
    push esi
    add esi, NAME_SIZE
    push esi
    sub esi, NAME_SIZE
    
    inc ecx
    push ecx
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
    
    push search_buffer
    push scan_str
    call _scanf
    add esp, 8
    call _getchar
    
    push header_search
    call _printf
    add esp, 4
    
    xor ecx, ecx
    mov dword [ebp-4], 0  ; Found counter
    
.search_loop:
    cmp ecx, [employee_count]
    jge .check_found
    
    mov eax, ecx
    mov ebx, 100
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
    push ecx
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
    
    pop ecx
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
    
    xor ecx, ecx
    
.display_loop:
    cmp ecx, [employee_count]
    jge .done
    
    mov eax, ecx
    mov ebx, 100
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
    
    pop esi
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
    sub esp, 200  ; Space for tracking displayed positions
    
    mov eax, [employee_count]
    test eax, eax
    jz .empty
    
    push header_grouped
    call _printf
    add esp, 4
    
    xor ecx, ecx  ; Outer loop
    
.outer_loop:
    cmp ecx, [employee_count]
    jge .done
    
    ; Get position of current employee
    mov eax, ecx
    mov ebx, 100
    mul ebx
    mov esi, employees
    add esi, eax
    add esi, NAME_SIZE
    
    ; Check if we already displayed this position
    push ecx
    push esi
    lea edi, [ebp-200]
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
    
    ; Store this position as displayed
    push ecx
    push esi
    mov eax, ecx
    mov ebx, NAME_SIZE
    mul ebx
    lea edi, [ebp-200]
    add edi, eax
    
    push esi
    push edi
    call _strcpy
    add esp, 8
    
    pop esi
    pop ecx
    
    ; Display position header
    push esi
    push format_position_header
    call _printf
    add esp, 8
    
    ; Display all employees with this position
    push ecx
    xor edx, edx
    
.inner_loop:
    cmp edx, [employee_count]
    jge .inner_done
    
    mov eax, edx
    mov ebx, 100
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
    
    push edx
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
    pop edx

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