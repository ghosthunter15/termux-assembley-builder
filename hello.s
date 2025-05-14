.section .data
msg: .asciz "Hello from AArch64 Termux!\n"

.section .text
.global _start
_start:
    ldr x0, =msg        // x0 = pointer to message
    mov x1, #26         // x1 = length of message
    mov x2, #1          // x2 = file descriptor (stdout)
    mov x8, #64         // syscall number for write
    svc 0

    mov x0, #0          // exit code
    mov x8, #93         // syscall number for exit
    svc 0
