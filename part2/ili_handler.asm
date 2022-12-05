.globl my_ili_handler
.extern what_to_do, old_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  ####### Some smart student's code here #######

  # save registers
  push %rax
  push %rbx
  push %rcx
  push %rdx
  push %rsi
  push %rdi
  push %r8
  push %r9
  push %r10
  push %r11
  push %r12
  push %r13
  push %r14
  push %r15
  push %rbp

  # save flags
  pushfq

  mov 128(%rsp), %bl

  #we have RIP pointing to the OPCODE
  mov $0, %rdi
  cmpb %bl, $0x0f
  je .call_What_To_Do_2bytes
    //call what to do with 1 byte.000f
    mov %bl, %dil
    mov $1, %rsi

    jmp .continue
  .call_What_To_Do_2bytes:
    mov 1(%rip), %dil
    mov $2, %rsi

.continue:
  call what_to_do

  cmp $0, %rax
  je .pass_to_old_handler
  
  mov %rax, %rdi
  mov 128(%rsp), %rcx
  add %rsi, %rcx
  mov %rcx, 128(%rsp)
  jmp .exit

.pass_to_old_handler:
  #restore registers
    popfq
    pop %rbp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rbx
    pop %rax
 #pass to old handler
  jmp *old_ili_handler
 

.exit:
  popfq
  pop %rbp
  pop %r15
  pop %r14
  pop %r13
  pop %r12
  pop %r11
  pop %r10
  pop %r9
  pop %r8
  pop %rsi # skip rdi
  pop %rsi
  pop %rdx
  pop %rcx
  pop %rbx
  pop %rax
  iretq
