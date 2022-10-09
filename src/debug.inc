.FEATURE pc_assignment

;==============================================================================
; Create a breakpoint marker
;
; Usage:
;  lda #$20
;  DEBUG_BREAK
;==============================================================================
.macro DEBUG_BREAK
; define some macro-local values
.local CALLER, START, END, PC
; get reference to current pc value
CALLER = *
; import the ROM location of the currently selected segment
.import .ident (.concat ("__", SEGMENT_NAME, "_FILEOFFS__"))
.import .ident (.concat ("__", SEGMENT_NAME, "_START__"))
; switch to the DEBUG segment to print our debug info
.pushseg
.segment "DEBUG"
; write the length of our debug command
.byte END-START
START:
; write the type of debug operation
.byte 0
; write the full offset in the ROM file to the caller
.out ">>> *DEBUG* marking breakpoint"
; oh god..
;  - FILEOFFS is the offset into the ROM of the segment
;  - CALLER is the org-based offset into the bank
;  - START is the org-based start of the segment!
; so with those we can determine exactly where in the ROM file we are, and subtract $10 for INES header
.faraddr .ident (.concat ("__", SEGMENT_NAME, "_FILEOFFS__")) + CALLER - .ident (.concat ("__", SEGMENT_NAME, "_START__")) - $10
; and i guess for now we need the CPU address as well. sad. SAD.
.addr CALLER
END:
; then switch back to the callers segment, restore pc, and exit
.popseg
* = CALLER
.endmacro

;==============================================================================
; Create a trace marker
;
; Usage:
;  lda #$20
;  DEBUG_TRACE "Trace message"
;==============================================================================
.macro DEBUG_TRACE msg
; define some macro-local values
.local CALLER, START, END, PC
; get reference to current pc value
CALLER = *
; import the ROM location of the currently selected segment
.import .ident (.concat ("__", SEGMENT_NAME, "_FILEOFFS__"))
.import .ident (.concat ("__", SEGMENT_NAME, "_START__"))
; switch to the DEBUG segment to print our debug info
.pushseg
.segment "DEBUG"
; write the length of our debug command
.byte END-START
START:
; write the type of debug operation
.byte 1
; write the full offset in the ROM file to the caller
.out ">>> *DEBUG* marking tracepoint"
; oh god..
;  - FILEOFFS is the offset into the ROM of the segment
;  - CALLER is the org-based offset into the bank
;  - START is the org-based start of the segment!
; so with those we can determine exactly where in the ROM file we are, and subtract $10 for INES header
.faraddr .ident (.concat ("__", SEGMENT_NAME, "_FILEOFFS__")) + CALLER - .ident (.concat ("__", SEGMENT_NAME, "_START__")) - $10
; and i guess for now we need the CPU address as well. sad. SAD.
.addr CALLER
.byte msg
END:
; then switch back to the callers segment, restore pc, and exit
.popseg
* = CALLER
.endmacro






.define SEGMENT_NAME "NONE"

.macro setsegment name
.undefine .ident("SEGMENT_NAME")
.segment name
.define .ident("SEGMENT_NAME") name
.endmacro
