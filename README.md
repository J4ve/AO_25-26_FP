# Architecture and Organization Final Project

[Document]((Group5_BSCS3A_Bacsain_Bongalos_Ortinero_Ricafort.pdf))

# Requirements:

## Employee Record Tracker

#### Add: Employee with Name and Position
#### Delete:
- Delete by Name
- Delete by Position
#### Search:
- Search by Name
- Search by Position
#### Display:
- Display all employees
- Display employees by position (grouped view)


The program should have a menu and employ [modular programming](modular-programming.pdf). 

**Error handling** and **input validation** should be present.

For the **ADD** function: **At least 10** entries

Upload a recorded video/s of you discussing your project and covering all the needed functions for your program on YouTube.

Be sure when you explain, your faces can be seen in the video. All members should be present in the video.

**ONLY ONE** Member will submit the final documentation file and this will be submitted thru LeOnS on or before due date. 10 points deduction/day is incurred for late submission.

---

## Implementation Features

### Core Functions
- **Add Employee**: Store name and position (max 31 chars each, up to 500 employees)
  - Multi-word input support with automatic whitespace trimming
  - Duplicate name detection with y/n confirmation prompt
  
- **Delete Employee**: Remove by name or position
  - Multi-match deletion with automatic array compaction
  
- **Search Employee**: Find by name or position
  - Displays all matching results with column headers (NO., NAME, POSITION)
  
- **Display Employees**: View all or grouped by position
  - Formatted tables with proper alignment and numbering

### Error Handling
- **Menu validation**: Handles invalid input and out-of-range choices
- **Input validation**: Enforces 31-character limit with re-prompting
- **Database capacity**: Prevents adding beyond 500 employees
- **Empty database checks**: All operations validate database is not empty before proceeding
- **Buffer management**: Properly clears stdin to prevent input carryover

### Technical Details
- **Language**: x86 Assembly (NASM, 32-bit)
- **Architecture**: Modular programming with cdecl calling convention
- **Memory**: 32KB array (500 × 64 bytes per employee)
- **UI**: 63-character width borders with formatted tables