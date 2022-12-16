.global count_above

.section .data
input: .fill 20, 1, 0
current_num: .fill 20, 1, 0

.section .text
count_above:          # input: rdi - seperator character
                      # output: rax - number of elements above 10
    push %rbp
    movq %rsp, %rbp

    mov $0, %r15     # set current input index to 0
    movb %dil, %r8b
    movq %rsi, %r9
    call get_path     # get path to file in %rax
    movq %rax, %rbx   # save path in %rbx

    movq $2, %rax     # open file
    movq %rbx, %rdi
    movq $0, %rsi
    syscall

    movq %rax, %r10   # save file descriptor in %r10
  
# input - the array of numbers, %rax - num of characters read
    
    movq $0, %rbx     # set current input index to 0
    movq $0, %rdi
    movq $0, %rdx
    movq $0, %r12     # count number of elements above x
    movq $0, %rax
    lea input(%rip), %r13 # set input array

# call read_from_file
    call .read_from_file
.fetch_num_loop:
    call .fetch_num   # fetch number from input array

    cmpq %r9, %rax    # compare current number to limit
    jle .below_limit  # if above limit, jump to above_limit
    incq %r12         # else, increment number of elements above limit


.below_limit:
    cmpb $0, (%r13, %rdx)
    je .end           # if end of input, jump to end
    jmp .fetch_num_loop

.end:
    
    movq $3, %rax     # set to sys_close
    movq %r10, %rdi   # set descriptor to %rdi
    syscall           # close file

    movq %r12, %rax   # set return value to number of elements above limit
    pop %rbp
    ret

############################################################################################
# Functions #
############################################################################################

# param - seperator, will be in %rdi
# variable for  the number in %rcx 
# param - 
# returns num value in %rax, current index in %rdx
.fetch_num:
    push %rbp
    movq %rsp, %rbp
    
    lea current_num(%rip), %rdi #passing parameter

    movq $0, %rsi
    movq $0, %rcx
  .loop_till_seperator:
        mov (%r13, %rdx), %cl
        cmpb %cl, %r8b
        je .seperator_found

        cmpb $0, %cl     # check for end of input
        je .end_func

        movb %cl, (%rdi, %rsi)
        inc %rsi
        inc %rdx

        cmp $20, %rdx     # check if we need to read more
        jne .loop_till_seperator
        add %rsi, %r15
        call .read_from_file

        jmp .loop_till_seperator
    .seperator_found:
        cmp $19, %rdx     # check if we need to read more
        jne .dont_read
        add %rsi, %r15
        call .read_from_file
        jmp .end_func
        
    .dont_read:
        inc %rdx
    .end_func:
      # return num in %rax, current index in %rdx
      movb $0, (%rdi, %rsi)
      # backup rsi, rdx, rcx, r8, r9, r10
      push %rsi
      push %rdx
      push %rcx
      push %r8
      push %r9
      push %r10
      push %rdi
      lea current_num(%rip), %rdi
      mov $0, %rax
      # dec stack pointer
      call atam_atol
      pop %rdi
      pop %r10
      # restore rsi, rdx, rcx, r8, r9, r10
      pop %r9
      pop %r8
      pop %rcx
      pop %rdx
      pop %rsi
    pop %rbp
    ret

############################################################################################
# Read Function #
############################################################################################

.read_from_file:
    push %rbp
    movq %rsp, %rbp
    push %rsi
    push %rdi
    
    movq $0, %rax     # set to sys_read 
    lea input(%rip), %rsi # set read path
    movq %r10, %rdi   # set descriptor to %rdi
    movq $20, %rdx    # set read length
    syscall           # read file

    cmp $20, %rax     # check if we need to read more
    jge .read_from_file_end     # if not, terminate

.terminate:
    movb $0, (%r13, %rax)

.read_from_file_end:

    mov $0, %rdx
    pop %rdi
    pop %rsi
    pop %rbp
    ret


